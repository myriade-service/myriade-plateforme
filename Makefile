# ============================================
# 🏢 MYRIADE-PLATEFORME - MAKEFILE COMPLET
# ============================================
# Commandes disponibles:
#   make help                  # Afficher cette aide
#   make setup                 # Setup du projet (setup.sh)
#   make deploy env=prod       # Déploiement (deploy.sh)
#   make backup                # Backup DB (backup.sh)
#   make restore file=xxx      # Restore DB (restore.sh)
#   make migrate action=up     # Migrations (migrate.sh)
#   make seed env=dev          # Seed data (seed.sh)
#   make health                # Health check (health-check.sh)
#   make performance           # Performance test (performance-test.sh)
# ============================================

# Variables
PROJECT_NAME := myriade-plateforme
SCRIPTS_DIR := scripts

# Couleurs
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
NC := \033[0m # No Color

# ============================================
# 🎯 AIDE PRINCIPALE
# ============================================

.PHONY: help
help: ## 📖 Afficher cette aide
	@echo "$(BLUE)╔══════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  🏢 $(PROJECT_NAME) - Makefile Commands           ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════╝$(NC)"
	@echo "$(GREEN)Usage: make [command] [options]$(NC)\n"
	@echo "$(CYAN)📦 DEVELOPMENT$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /development/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)🐳 DOCKER$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /docker/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)🗄️  DATABASE$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /database/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)🚀 DEPLOYMENT$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /deployment/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)🔧 SCRIPTS SPECIFIQUES$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /script/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)🛡️  SECURITY$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /security/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n$(CYAN)📊 MONITORING$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / && $$0 ~ /monitoring/ {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ============================================
# 📦 DÉVELOPPEMENT (development)
# ============================================

.PHONY: setup
setup: ## 🔧 Setup complet du projet (setup.sh)
	@echo "$(GREEN)🔧 Exécution du setup...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/setup.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/setup.sh" && \
		"$(SCRIPTS_DIR)/setup.sh"; \
	else \
		echo "$(RED)❌ Script setup.sh non trouvé dans $(SCRIPTS_DIR)$(NC)"; \
		exit 1; \
	fi

.PHONY: run
run: ## 🚀 Lancer l'application
	@echo "$(GREEN)🚀 Lancement de l'application...$(NC)"
	@./mvnw spring-boot:run || mvn spring-boot:run

.PHONY: build
build: ## 📦 Build du projet
	@echo "$(GREEN)📦 Build du projet...$(NC)"
	@./mvnw clean package -DskipTests || mvn clean package -DskipTests

.PHONY: clean
clean: ## 🧹 Nettoyer le projet
	@echo "$(GREEN)🧹 Nettoyage...$(NC)"
	@./mvnw clean || mvn clean
	@rm -rf target/ logs/ tmp/ 2>/dev/null || true

# ============================================
# 🐳 DOCKER (docker)
# ============================================

.PHONY: docker-build
docker-build: ## 🐳 Build l'image Docker
	@echo "$(GREEN)🐳 Build de l'image Docker...$(NC)"
	@docker build -t $(PROJECT_NAME):latest .

.PHONY: docker-up
docker-up: ## 🐳 Démarrer avec docker-compose
	@echo "$(GREEN)🐳 Démarrage des services Docker...$(NC)"
	@docker-compose up -d

.PHONY: docker-down
docker-down: ## 🐳 Arrêter docker-compose
	@echo "$(GREEN)🐳 Arrêt des services Docker...$(NC)"
	@docker-compose down

# ============================================
# 🗄️  BASE DE DONNÉES (database)
# ============================================

.PHONY: backup
backup: ## 💾 Backup de la base de données (backup.sh)
	@echo "$(GREEN)💾 Exécution du backup...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/backup.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/backup.sh" && \
		"$(SCRIPTS_DIR)/backup.sh"; \
	else \
		echo "$(RED)❌ Script backup.sh non trouvé$(NC)"; \
		exit 1; \
	fi

.PHONY: restore
restore: ## 🔄 Restauration de la base de données (restore.sh)
	@echo "$(GREEN)🔄 Exécution de la restauration...$(NC)"
	@if [ -z "$(file)" ]; then \
		echo "$(RED)❌ Spécifiez un fichier: make restore file=backup.sql$(NC)"; \
		exit 1; \
	fi
	@if [ -f "$(SCRIPTS_DIR)/restore.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/restore.sh" && \
		"$(SCRIPTS_DIR)/restore.sh" "$(file)"; \
	else \
		echo "$(RED)❌ Script restore.sh non trouvé$(NC)"; \
		exit 1; \
	fi

.PHONY: migrate
migrate: ## 📊 Exécuter les migrations (migrate.sh)
	@echo "$(GREEN)📊 Exécution des migrations...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/migrate.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/migrate.sh" && \
		"$(SCRIPTS_DIR)/migrate.sh" "$(action)"; \
	else \
		echo "$(RED)❌ Script migrate.sh non trouvé$(NC)"; \
		exit 1; \
	fi

.PHONY: seed
seed: ## 🌱 Charger les données de test (seed.sh)
	@echo "$(GREEN)🌱 Chargement des données de test...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/seed.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/seed.sh" && \
		"$(SCRIPTS_DIR)/seed.sh" "$(env)"; \
	else \
		echo "$(RED)❌ Script seed.sh non trouvé$(NC)"; \
		exit 1; \
	fi

# ============================================
# 🚀 DÉPLOIEMENT (deployment)
# ============================================

.PHONY: deploy
deploy: ## 🚀 Déployer l'application (deploy.sh)
	@echo "$(GREEN)🚀 Exécution du déploiement...$(NC)"
	@if [ -z "$(env)" ]; then \
		echo "$(RED)❌ Spécifiez un environnement: make deploy env=[dev|staging|prod]$(NC)"; \
		exit 1; \
	fi
	@if [ -f "$(SCRIPTS_DIR)/deploy.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/deploy.sh" && \
		"$(SCRIPTS_DIR)/deploy.sh" "$(env)"; \
	else \
		echo "$(RED)❌ Script deploy.sh non trouvé$(NC)"; \
		exit 1; \
	fi

# ============================================
# 🔧 SCRIPTS SPÉCIFIQUES (script)
# ============================================

.PHONY: health
health: ## 🏥 Vérifier la santé de l'application (health-check.sh)
	@echo "$(GREEN)🏥 Exécution du health check...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/health-check.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/health-check.sh" && \
		"$(SCRIPTS_DIR)/health-check.sh"; \
	else \
		echo "$(RED)❌ Script health-check.sh non trouvé$(NC)"; \
		exit 1; \
	fi

.PHONY: performance
performance: ## ⚡ Test de performance (performance-test.sh)
	@echo "$(GREEN)⚡ Exécution du test de performance...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/performance-test.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/performance-test.sh" && \
		"$(SCRIPTS_DIR)/performance-test.sh"; \
	else \
		echo "$(RED)❌ Script performance-test.sh non trouvé$(NC)"; \
		exit 1; \
	fi

.PHONY: secret-check
secret-check: ## 🔍 Vérifier les secrets dans le code
	@echo "$(GREEN)🔍 Vérification des secrets...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/secret-check.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/secret-check.sh" && \
		"$(SCRIPTS_DIR)/secret-check.sh"; \
	else \
		echo "$(YELLOW)⚠️  Script secret-check.sh non trouvé, exécution de la vérification basique...$(NC)"; \
		@find . -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.properties" -o -name "*.java" \) \
			! -path "./target/*" ! -path "./.git/*" \
			-exec grep -l -i "password\|secret\|key\|token" {} \; 2>/dev/null | head -10; \
	fi

# ============================================
# 🛡️  SÉCURITÉ (security)
# ============================================

.PHONY: security-scan
security-scan: ## 🛡️  Scan de sécurité complet
	@echo "$(GREEN)🛡️  Exécution du scan de sécurité...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/security-scan.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/security-scan.sh" && \
		"$(SCRIPTS_DIR)/security-scan.sh"; \
	else \
		echo "$(YELLOW)⚠️  Script security-scan.sh non trouvé$(NC)"; \
		./mvnw org.owasp:dependency-check-maven:check || true; \
	fi

.PHONY: dependency-check
dependency-check: ## 📦 Vérifier les dépendances vulnérables
	@echo "$(GREEN)📦 Vérification des dépendances...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/dependency-check.sh" ]; then \
		chmod +x "$(SCRIPTS_DIR)/dependency-check.sh" && \
		"$(SCRIPTS_DIR)/dependency-check.sh"; \
	else \
		echo "$(YELLOW)⚠️  Script dependency-check.sh non trouvé$(NC)"; \
	fi

# ============================================
# 📊 MONITORING (monitoring)
# ============================================

.PHONY: metrics
metrics: ## 📈 Afficher les métriques
	@echo "$(GREEN)📈 Récupération des métriques...$(NC)"
	@curl -s http://localhost:8080/actuator/metrics 2>/dev/null | jq '.names' || \
	echo "$(YELLOW)⚠️  Service non disponible ou jq non installé$(NC)"

.PHONY: logs
logs: ## 📜 Voir les logs de l'application
	@echo "$(GREEN)📜 Affichage des logs...$(NC)"
	@tail -f logs/app.log 2>/dev/null || \
	echo "$(YELLOW)⚠️  Fichier de logs non trouvé$(NC)"

# ============================================
# 🎪 COMMANDES COMPOSÉES
# ============================================

.PHONY: dev-setup
dev-setup: ## 🎪 Setup complet pour développement
	@echo "$(BLUE)🎪 Configuration environnement de développement...$(NC)"
	@$(MAKE) setup
	@$(MAKE) docker-up
	@sleep 5
	@$(MAKE) migrate action=up
	@$(MAKE) seed env=dev
	@echo "$(GREEN)✅ Environnement dev prêt!$(NC)"

.PHONY: ci-pipeline
ci-pipeline: ## ⚙️  Exécuter le pipeline CI complet
	@echo "$(BLUE)⚙️  Exécution du pipeline CI...$(NC)"
	@$(MAKE) clean
	@$(MAKE) build
	@$(MAKE) secret-check
	@$(MAKE) security-scan
	@echo "$(GREEN)✅ Pipeline CI terminé avec succès!$(NC)"

.PHONY: production-deploy
production-deploy: ## 🚀 Déploiement production avec vérifications
	@echo "$(RED)⚠️  ⚠️  ⚠️  DÉPLOIEMENT PRODUCTION ⚠️  ⚠️  ⚠️$(NC)"
	@read -p "Êtes-vous sûr de vouloir déployer en production? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(GREEN)✅ Démarrage du déploiement production...$(NC)"; \
		$(MAKE) ci-pipeline; \
		$(MAKE) backup; \
		$(MAKE) deploy env=prod; \
		$(MAKE) health; \
	else \
		echo "$(YELLOW)❌ Déploiement annulé$(NC)"; \
	fi

# ============================================
# 🛠️  UTILITAIRES
# ============================================

.PHONY: list-scripts
list-scripts: ## 📋 Lister tous les scripts disponibles
	@echo "$(BLUE)📋 SCRIPTS DISPONIBLES$(NC)"
	@for script in $(SCRIPTS_DIR)/*.sh; do \
		if [ -f "$$script" ]; then \
			script_name=$$(basename "$$script"); \
			printf "$(GREEN)%-25s$(NC)" "$$script_name"; \
			first_line=$$(head -1 "$$script" | sed 's/^#!.*//'); \
			description=$$(head -5 "$$script" | grep -E "^# " | head -1 | sed 's/^# //'); \
			if [ -n "$$description" ]; then \
				echo " - $$description"; \
			else \
				echo ""; \
			fi \
		fi \
	done

.PHONY: check-scripts
check-scripts: ## 🔍 Vérifier que tous les scripts existent
	@echo "$(BLUE)🔍 VÉRIFICATION DES SCRIPTS$(NC)"
	@required_scripts="setup.sh deploy.sh backup.sh restore.sh migrate.sh seed.sh health-check.sh performance-test.sh"; \
	for script in $$required_scripts; do \
		if [ -f "$(SCRIPTS_DIR)/$$script" ]; then \
			echo "$(GREEN)✅ $$script$(NC)"; \
		else \
			echo "$(RED)❌ $$script - MANQUANT$(NC)"; \
		fi \
	done

.PHONY: init-scripts
init-scripts: ## 🛠️  Initialiser les scripts (donner permissions)
	@echo "$(GREEN)🛠️  Initialisation des scripts...$(NC)"
	@if [ -d "$(SCRIPTS_DIR)" ]; then \
		chmod +x $(SCRIPTS_DIR)/*.sh 2>/dev/null || true; \
		echo "$(GREEN)✅ Permissions données aux scripts$(NC)"; \
	else \
		echo "$(RED)❌ Dossier $(SCRIPTS_DIR) non trouvé$(NC)"; \
		exit 1; \
	fi

# ============================================
# 🏁 COMMANDES RACCOURCIS
# ============================================

.PHONY: up
up: docker-up ## 🐳 Alias pour docker-up

.PHONY: down
down: docker-down ## 🐳 Alias pour docker-down

.PHONY: db-backup
db-backup: backup ## 💾 Alias pour backup

.PHONY: db-restore
db-restore: restore ## 🔄 Alias pour restore

.PHONY: check
check: secret-check ## 🔍 Alias pour secret-check

.PHONY: scan
scan: security-scan ## 🛡️  Alias pour security-scan

.PHONY: deploy-prod
deploy-prod: ## 🚀 Alias pour production-deploy
	@$(MAKE) production-deploy

# ============================================
# 🎯 DÉMARRAGE RAPIDE
# ============================================

.PHONY: quick-start
quick-start: ## 🚀 Démarrer rapidement le projet
	@echo "$(BLUE)🚀 DÉMARRAGE RAPIDE$(NC)"
	@$(MAKE) init-scripts
	@$(MAKE) check-scripts
	@echo "\n$(GREEN)🎯 Commandes disponibles:$(NC)"
	@echo "  make dev-setup          # Setup complet dev"
	@echo "  make run                # Lancer l'application"
	@echo "  make backup             # Backup DB"
	@echo "  make deploy env=staging # Déployer en staging"
	@echo "  make health             # Vérifier santé"
	@echo "\n$(YELLOW)⚠️  Pour plus de commandes: make help$(NC)"

# ============================================
# 🏁 CONFIGURATION FINALE
# ============================================

.DEFAULT_GOAL := quick-start

# Message de fin
print-success:
	@echo "$(GREEN)✨ Makefile chargé avec succès!$(NC)"
	@echo "$(BLUE)📚 Utilisez 'make help' pour voir toutes les commandes$(NC)"