# ═══════════════════════════════════════════════════════════
#  ZERO CLOUD SERVICE — Makefile
# ═══════════════════════════════════════════════════════════

COMPOSE = docker compose

.PHONY: up down stop restart status logs health reset help aws azure gcp uis sync update

## Sab kuch start (pehli baar image pull/build karega)
up:
	$(COMPOSE) up -d

## Sab stop (state bachi rahegi)
stop:
	$(COMPOSE) stop

## Stop + remove containers (data ./data/ me safe hai)
down:
	$(COMPOSE) down

## Restart
restart:
	$(COMPOSE) restart

## Container status
status:
	$(COMPOSE) ps

## Sab ke logs follow karo
logs:
	$(COMPOSE) logs -f --tail=50

## Health check sab endpoints ka
health:
	bash scripts/health-check.sh

## PURA DATA MITAO — fresh cloud (dhyan se!)
reset:
	$(COMPOSE) down
	rm -rf ./data
	mkdir -p ./data
	@echo "✅ Fresh cloud ready. Ab 'make up' chalao."

## Sirf AWS stack
aws:
	$(COMPOSE) up -d floci aws-emulator floci-ui

## Sirf Azure stack
azure:
	$(COMPOSE) up -d floci-az azurite floci-ui

## Sirf GCP stack
gcp:
	$(COMPOSE) up -d floci-gcp fake-gcs gcp-pubsub gcp-firestore gcp-datastore cloudbox gcp-ui floci-ui

## Sirf UIs
uis:
	$(COMPOSE) up -d floci-ui gcp-ui landing

## Upstream sync check — 9 repos ke naye commits/tags → upstream.yml refresh
sync:
	bash scripts/check-upstream.sh

## Images update — upstream ke naye versions pull karke containers recreate
update:
	$(COMPOSE) pull
	$(COMPOSE) up -d

help:
	@grep -E '^## ' Makefile | sed 's/## /  /'
