# Makefile for Medusa Docker Development

.PHONY: help build up down restart logs shell console db-console db-migrate db-reset test clean

help: ## Show this help message
	@echo "Medusa Docker Development Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	docker compose build

up: ## Start all services
	docker compose up -d
	@echo ""
	@echo "✓ Medusa is starting..."
	@echo "  URL: http://localhost:3000"
	@echo "  Default login: admin / admin123"
	@echo ""
	@echo "Run 'make logs' to view logs"

down: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

logs: ## View logs (all services)
	docker compose logs -f

logs-web: ## View Rails application logs only
	docker compose logs -f web

logs-db: ## View database logs only
	docker compose logs -f db

shell: ## Open bash shell in web container
	docker compose exec web bash

console: ## Open Rails console
	docker compose exec web bundle exec rails console

db-console: ## Open PostgreSQL console
	docker compose exec db psql -U medusa -d medusa_development

db-migrate: ## Run database migrations
	docker compose exec web bundle exec rake db:migrate

db-rollback: ## Rollback last migration
	docker compose exec web bundle exec rake db:rollback

db-seed: ## Seed database
	docker compose exec web bundle exec rake db:seed

db-reset: ## Reset database (WARNING: deletes all data)
	@echo "WARNING: This will delete all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose exec web bundle exec rake db:reset; \
	fi

test: ## Run RSpec tests
	docker compose exec web bundle exec rspec

guard: ## Run Guard for auto-testing
	docker compose exec web bundle exec guard

clean: ## Remove all containers, volumes, and images
	docker compose down -v
	docker rmi medusa-earthshape-web || true

rebuild: clean build up ## Clean rebuild (removes everything and rebuilds)

ps: ## Show running containers
	docker compose ps

stats: ## Show container resource usage
	docker stats
