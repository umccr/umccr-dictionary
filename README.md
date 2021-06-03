# UMCCR Data Dictionary

UMCCR Data Dictionary for Gen3 platform


## Development

- Required:
  - [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - [GNU Make](https://www.gnu.org/software/make/)
    - GNU Make comes with most Linux and macOS Xcode
    - Try `make --version` to see whether you already have it in   
    - Otherwise `brew install make` for macOS and try like `gmake --version`
    - On Ubuntu, `sudo apt-get install build-essential`
    - If make is not possible then you will need to execute each target in [Makefile](Makefile)

## Workflow

### Basic

- Bring up the stack
```
make up
```

- Check the stack
```
docker ps -a
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

### Modify

- Modify schema yaml files in `dictionary/umccr/`

- Convert into JSON
```
make umccr
```

- Visit to: http://localhost:8080/#schema/umccr.json

- Reload the page (do twice if necessary)
