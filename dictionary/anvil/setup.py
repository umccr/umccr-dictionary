import importlib
from subprocess import check_call

from setuptools import setup, find_packages
from setuptools.command.install import install

BANNER = "AnVIL"


class InstallCommand(install):
    def run(self):
        check_call("pip uninstall -y gen3dictionary".split())
        check_call("pip -q --disable-pip-version-check install art".split())
        if importlib.util.find_spec("art") is not None:
            from art import tprint
            tprint(BANNER)
        install.run(self)


setup(
    name='gdcdictionary',
    version='0.0.0',
    packages=find_packages(),
    install_requires=[
        # 'dictionaryutils',
    ],
    package_data={
        "gdcdictionary": [
            "schemas/*.yaml",
            "schemas/projects/*.yaml",
            "schemas/projects/*/*.yaml",
        ]
    },
    cmdclass={
        'install': InstallCommand,
    },
)
