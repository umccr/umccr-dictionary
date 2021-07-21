.PHONY: test


# backwards compatibility: dd is a synonym for program, default project to "simulated"
program ?= $(dd)
project ?= simulated

# read environmental variables from same config file that shared with docker-compose
ifneq ("$(wildcard .env)","")
  $(info Using .env)
  include .env
  export $(shell sed 's/=.*//' .env)
else
  $(info Using .env-sample)
  include .env-sample
  export $(shell sed 's/=.*//' .env-sample)
endif


# -- Base targets

up:
	@docker compose up -d

down:
	@docker compose down

restart:
	@docker compose restart

ps:
	@docker compose ps


# -- DBA targets: may require SA (sysadmin) privilege for PostgreSQL

psql:
	@docker exec -e PGPASSWORD=$(PG_PASS) -it ddpostgres psql -h $(PG_HOST) -d $(PG_NAME) -U $(PG_USER)

reset:
	@docker exec -e PGPASSWORD=$(POSTGRES_PASSWORD) -it ddpostgres \
		psql \
		 --set=postgres_user=$(POSTGRES_USER) \
		 --set=pg_user=$(PG_USER) \
		 -h $(PG_HOST) -d $(PG_NAME) -U $(POSTGRES_USER) -f /sql/reset.sql


# -- DD targets

# Use this way if you are trouble calling this make convert target:
#   docker compose exec g3po g3po dd convert /dictionary/umccr/gdcdictionary/schemas --out /schema/umccr.json
convert:
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make convert program=umccr"; exit 1; }	
	@rm -f schema/$(program).json
	@docker compose exec g3po g3po dd convert /dictionary/$(program)/gdcdictionary/schemas --out /schema/$(program).json

# alias to convert
compile: convert


# Use this way if you are trouble calling this make test target:
#   docker run --rm -v $(pwd)/dictionary/umccr:/dictionary quay.io/cdis/dictionaryutils:master
test:
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make test program=umccr project=simulated"; exit 1; }
	@[ -n "$(project)" ] || { echo "Please specify project argument e.g.  make test program=umccr project=simulated"; exit 1; }
	@echo Testing Data Dictionary: $(program)
	@docker run --rm -v $(shell pwd)/dictionary/$(program):/dictionary quay.io/cdis/dictionaryutils:master


# Use this way if you are trouble calling this make validate target:
#   docker exec -it ddsim data-simulator validate --url http://ddvis/schema/umccr.json
validate:
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make validate program=umccr project=simulated"; exit 1; }
	@[ -n "$(project)" ] || { echo "Please specify project argument e.g.  make validate program=umccr project=simulated"; exit 1; }
	@echo Validating Data Dictionary: $(program)
	@docker exec -it ddsim data-simulator validate --url http://ddvis/schema/$(program).json


# Use this way if you are trouble calling this make simulate target:
#   docker exec -it ddsim data-simulator simulate --url http://ddvis/schema/umccr.json --path /data --program program1 --project project1 --max_samples 10
simulate: validate
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make simulate program=umccr project=simulated"; exit 1; }
	@[ -n "$(project)" ] || { echo "Please specify project argument e.g.  make simulate program=umccr project=simulated"; exit 1; }
	@echo Simulating Data Dictionary: $(program)
	@mkdir -p data/$(program)/$(project)
	@rm -f data/$(program)/$(project)/*.*
	@docker exec -it ddsim data-simulator simulate --url http://ddvis/schema/$(program).json --path /data/$(program)/$(project) --program $(program) --project $(project) --max_samples 10

	@test -f data/$(program)/$(project)/DataImportOrder.txt  || { echo "data/$(program)/$(project)/DataImportOrder.txt does not exist" ; exit 1; }
	@echo "data/$(program)/$(project)/DataImportOrder.txt exists."

	@echo "program\n`cat data/$(program)/$(project)/DataImportOrder.txt`"  > data/$(program)/$(project)/DataImportOrder.txt
	@grep -q program data/$(program)/$(project)/DataImportOrder.txt || { echo "no 'program' found data/$(program)/$(project)/DataImportOrder.txt" ; exit 1; }
	@echo "'program' added to data/$(program)/$(project)/DataImportOrder.txt"

	@echo '{ "name": "$(program)", "dbgap_accession_number": "$(program)", "submitter_id": "$(program)", "type": "program" }' > data/$(program)/$(project)/program.json
	@test -f data/$(program)/$(project)/program.json  || { echo "data/$(program)/$(project)/program.json does not exist" ; exit 1; }
	@echo "created data/$(program)/$(project)/program.json"


# Use this way if you are trouble calling this make load target:
#   docker exec -it dmutils datamodel_postgres_admin create-all --dict-url http://ddvis/schema/umccr.json
load:
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make test program=umccr project=simulated"; exit 1; }
	@echo Loading Data Dictionary: $(program)
	@docker exec -it dmutils datamodel_postgres_admin create-all --dict-url http://ddvis/schema/$(program).json


import:
	@[ -n "$(program)" ] || { echo "Please specify program argument e.g.  make import program=umccr project=simulated"; exit 1; }
	@[ -n "$(project)" ] || { echo "Please specify project argument e.g.  make import program=umccr project=simulated"; exit 1; }
	@echo Importing Simulated Test Data: program=$(program) project=$(project)
	@rm -rf output/$(program)/$(project)
	@mkdir -p output/$(program)/$(project)
	@docker exec -it ddimporter sh -c "importer --program $(program) --project $(project) --delete_first True | sh "	
