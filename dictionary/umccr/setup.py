from setuptools import setup, find_packages

setup(
    name='gdcdictionary',
    version='0.0.0',
    packages=find_packages(),
    install_requires=[
        'dictionaryutils',
    ],
    package_data={
        "gdcdictionary": [
            "schemas/*.yaml",
            "schemas/projects/*.yaml",
            "schemas/projects/*/*.yaml",
        ]
    },
)
