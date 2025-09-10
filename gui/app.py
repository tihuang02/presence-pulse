import os
import argparse
import json
import asyncio
import aiohttp
import pychrome
import subprocess

def get_profile_dir(profile_dir=None):
    if profile_dir is not None:
        return os.path.expanduser(os.path.join("~", ".config", "chromium-profile", profile_dir))
    else:
        return os.path.expanduser("~/.config/presencepulse/chromium-profile")

class PresencePulse:
    def __init__(self):
        self.config = self.load_config()

    def load_config(self):
        config_path = os.path.join(os.path.dirname(__file__), "../config/config.json")
        try:
            with open(config_path) as f:
                return json.load(f)
        except Exception as e:
            print(f"⚠️ Failed to load config: {e}")
            return {}

    def launch_chromium(self):
        parser = argparse.ArgumentParser(description='Launches a Chrome instance with Presence Pulse')
        parser.add_argument('--profile-dir', type=str, help='Path to directory for user data (e.g. "app")')
        args = parser.parse_args()
        config = self.config
        url = self.config["teams_url"]
        size = ",".join(map(str, config["window_size"]))
        profile_dir = get_profile_dir(args.profile_dir)

        cmd = [
            "chromium",
            f"--app={url}",
            f"--window-size={size}",
            f"--user-data-dir={profile_dir}",
            "--no-default-browser-check",
            "--disable-infobars",
            "--disable-session-crashed-bubble",
            "--remote-debugging-port=9222",
        ]

        subprocess.Popen(cmd)

    async def wait_for_devtools(self, timeout=30):
        url = "http://127.0.0.1:9222/json"
        for _ in range(timeout):
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(url) as resp:
                        if resp.status == 200:
                            print("✅ DevTools is ready.")
                            return True
            except aiohttp.ClientError:
                pass
            await asyncio.sleep(1)
        print("❌ DevTools did not become ready in time.")
        return False

    async def monitor_devtools(self):
        url = "http://127.0.0.1:9222/json"
        while True:
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(url) as resp:
                        if resp.status != 200:
                            print("❌ DevTools returned non-200 status. Exiting.")
                            os._exit(0)
            except Exception:
                print("❌ DevTools unreachable. Exiting.")
                os._exit(0)
            await asyncio.sleep(10)

    async def inject_mousemove(self):
        while True:
            try:
                browser = pychrome.Browser(url="http://127.0.0.1:9222")
                tabs = browser.list_tab()
                for tab in tabs:
                    try:
                        tab.start()
                        tab.Runtime.evaluate(expression="""
                            window.dispatchEvent(new MouseEvent('mousemove', {
                                bubbles: true,
                                cancelable: true,
                                clientX: Math.floor(Math.random() * window.innerWidth),
                                clientY: Math.floor(Math.random() * window.innerHeight)
                            }));
                            console.log("🟢 PresencePulse: mousemove dispatched");
                        """)
                        print(f"✅ Injected mousemove into tab: {tab.id}")
                        tab.stop()
                    except Exception as e:
                        print(f"⚠️ Injection failed for tab {tab.id}: {e}")
                        tab.stop()
            except Exception as e:
                print(f"❌ DevTools error during injection: {e}")
                os._exit(0)

            interval_seconds = self.config["interval_seconds"]
            await asyncio.sleep(interval_seconds)

    async def run(self):
        self.launch_chromium()
        ready = await self.wait_for_devtools()
        if not ready:
            return

        print("✅ PresencePulse is active.")
        await asyncio.gather(
            self.monitor_devtools(),
            self.inject_mousemove()
        )

def main():
    pulse = PresencePulse()
    asyncio.run(pulse.run())

if __name__ == "__main__":
    main()
