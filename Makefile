.PHONY: test

up:
	@docker compose up -d

down:
	@docker compose down

restart:
	@docker compose restart

ps:
	@docker compose ps

psql:
	@docker exec -it ddpostgres psql -h localhost -U metadata -w metadata

anvil:
	@docker compose exec g3po g3po dd convert /dictionary/anvil/gdcdictionary/schemas --out /schema/anvil.json

dcf:
	@docker compose exec g3po g3po dd convert /dictionary/dcf/gdcdictionary/schemas --out /schema/dcf.json

gdc:
	@docker compose exec g3po g3po dd convert /dictionary/gdc/gdcdictionary/schemas --out /schema/gdc.json

kf:
	@docker compose exec g3po g3po dd convert /dictionary/kf/gdcdictionary/schemas --out /schema/kf.json

umccr:
	@docker compose exec g3po g3po dd convert /dictionary/umccr/gdcdictionary/schemas --out /schema/umccr.json

# Parameterized compose, remove schema json before regenerating
convert:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make convert dd=umccr"; exit 1; }	
	rm -f schema/$(dd).json
	@docker compose exec g3po g3po dd convert /dictionary/$(dd)/gdcdictionary/schemas --out /schema/$(dd).json

# Use this way if you are trouble calling this make test target:
#   docker run --rm -v $(pwd)/dictionary/umccr:/dictionary quay.io/cdis/dictionaryutils:master
test:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make test dd=umccr"; exit 1; }
	@echo Testing Data Dictionary: $(dd)
	@docker run --rm -v $(shell pwd)/dictionary/$(dd):/dictionary quay.io/cdis/dictionaryutils:master

# Use this way if you are trouble calling this make validate target:
#   docker exec -it ddsim data-simulator validate --url http://ddvis/schema/umccr.json
validate:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make validate dd=umccr"; exit 1; }
	@echo Validating Data Dictionary: $(dd)
	@docker exec -it ddsim data-simulator validate --url http://ddvis/schema/$(dd).json

# Use this way if you are trouble calling this make simulate target:
#   docker exec -it ddsim data-simulator simulate --url http://ddvis/schema/umccr.json --path /data --program program1 --project project1 --max_samples 10
simulate: validate
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make simulate dd=umccr"; exit 1; }
	@echo Simulating Data Dictionary: $(dd)
	@docker exec -it ddsim data-simulator simulate --url http://ddvis/schema/$(dd).json --path /data/$(dd) --program program1 --project project1 --max_samples 10

# Use this way if you are trouble calling this make load target:
#   docker exec -it dmutils datamodel_postgres_admin create-all --dict-url http://ddvis/schema/umccr.json
load:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make load dd=umccr"; exit 1; }
	@echo Loading Data Dictionary: $(dd)
	@docker exec -it dmutils datamodel_postgres_admin create-all --dict-url http://ddvis/schema/$(dd).json

reset:
	@docker exec -it ddpostgres psql -h localhost -U postgres -w metadata -f /sql/reset.sql

import:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make load dd=umccr"; exit 1; }
	@echo Importing Simulated Test Data: $(dd)
	@docker exec -it importer sh -c "importer --program ohsu --project $(dd) | sh "
