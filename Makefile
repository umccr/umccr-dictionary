up:
	@docker compose up -d

down:
	@docker compose down

restart:
	@docker compose restart

ps:
	@docker compose ps

anvil:
	@docker compose exec g3po g3po dd convert /dictionary/anvil --out /schema/anvil.json

dcf:
	@docker compose exec g3po g3po dd convert /dictionary/dcf --out /schema/dcf.json

gdc:
	@docker compose exec g3po g3po dd convert /dictionary/gdc --out /schema/gdc.json

kf:
	@docker compose exec g3po g3po dd convert /dictionary/kf --out /schema/kf.json

umccr:
	@docker compose exec g3po g3po dd convert /dictionary/umccr --out /schema/umccr.json
