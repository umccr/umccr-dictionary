.PHONY: test

up:
	@docker compose up -d

down:
	@docker compose down

restart:
	@docker compose restart

ps:
	@docker compose ps

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

# Use this way if you are trouble calling this make test target:
#   docker run --rm -v $(pwd)/dictionary/umccr:/dictionary quay.io/cdis/dictionaryutils:master
test:
	@[ -n "$(dd)" ] || { echo "Please specify dd argument e.g.  make test dd=umccr"; exit 1; }
	@echo Testing Data Dictionary: $(dd)
	@docker run --rm -v $(shell pwd)/dictionary/$(dd):/dictionary quay.io/cdis/dictionaryutils:master
