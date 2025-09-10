from setuptools import setup, find_packages

setup(
    name="presencepulse",
    version="0.1.0",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "aiohttp",
        "pychrome",
    ],
    entry_points={
        "console_scripts": [
            "presencepulse=gui.app:main",
        ],
    },
)
