from setuptools import setup, find_packages

from importer import __version__

with open("README.md", "r") as f:
    long_description = f.read()

setup(
    name="importer",
    description="CLI utility to import Gen3 database directly, bypassing sheepdog.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/umccr/g3po",
    author="OHSU",
    author_email="walsbr@ohsu.edu",
    license="MIT",
    version=__version__,
    packages=find_packages(),
    entry_points={
        "console_scripts": ["importer=importer.importer:import_graph"],
    },
    install_requires=[
        "click>=7.1.2",
        "gen3>=4.2.0",
        "indexclient>=2.1",
        "dictionaryutils>=3.4.1",
    ],
    extras_require={
        "test": [
            "pytest",
        ],
        "dev": [
            "twine",
            "setuptools",
            "wheel",
        ],
    },
    python_requires=">=3.7",
)
