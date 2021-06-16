# UMCCR Data Dictionary

This repo contains Docker and Makefile based Data Dictionary Development workflow i.e., packaging around dictionary tools (Docker image) for conversion, visualisation, testing, validation to allow Data Modeller to iteratively develop schema locally. 

Our aim is to develop **UMCCR Data Dictionary** for Gen3 platform. 

## Development

- Required:
  - [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - [GNU Make](https://www.gnu.org/software/make/)
    - GNU Make comes with most Linux and macOS Xcode
    - Try `make --version` to see whether you already have it in   
    - Otherwise `brew install make` for macOS and try like `gmake --version`
    - On Ubuntu, try `apt-get install make`
    - If `make` is not possible then you will need to execute each target in [Makefile](Makefile)

## Workflow

### Basic

- Bring up the stack
```
make up
```

- Check the stack
```
make ps
```

- Restart the stack 
```
make restart
```

- Bring it down 
```
make down
```

### Visualisation

- Visit to: http://localhost:8080
- You can switch dictionary as follows:
  - `http://localhost:8080/#schema/<dictionary_name>.json` e.g.
  - http://localhost:8080/#schema/anvil.json
  - http://localhost:8080/#schema/dcf.json 
  - http://localhost:8080/#schema/gdc.json 
  - http://localhost:8080/#schema/kf.json

### Modifying Dictionary

- Say you are working on `umccr` dictionary
- Modify schema yaml files in `dictionary/umccr/`
- Convert into JSON
```
make umccr
```
- Visit to: http://localhost:8080/#schema/umccr.json
- Reload the page (_**do twice**_ if necessary)
