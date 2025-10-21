# AI Project Template - Universal Makefile v2.0
# Sistema avançado com session management e language detection
# Inspirado em enterprise-project-model patterns

# Configurações
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
CYAN := \033[0;36m
PURPLE := \033[0;35m
NC := \033[0m

# Variáveis
PROJECT_NAME ?= $(shell basename $(CURDIR))
SESSION_MANAGER := ./scripts/session-manager.py
LANGUAGE_DETECTOR := ./scripts/detect-language.py
PROJECT_CREATOR := ./scripts/create-project.sh
VERSION_MANAGER := ./scripts/version-manager.py
FRAMEWORK_DETECTOR := ./scripts/framework-detector.py
COPILOT_SETUP := ./scripts/copilot-setup.sh
SECURITY_CLEANUP := ./scripts/security-cleanup.sh

# Verificar se scripts existem
SCRIPTS_AVAILABLE := $(shell test -f $(SESSION_MANAGER) && test -f $(LANGUAGE_DETECTOR) && echo "true" || echo "false")
VERSION_AVAILABLE := $(shell test -f $(VERSION_MANAGER) && echo "true" || echo "false")
FRAMEWORK_AVAILABLE := $(shell test -f $(FRAMEWORK_DETECTOR) && echo "true" || echo "false")
COPILOT_AVAILABLE := $(shell test -f $(COPILOT_SETUP) && echo "true" || echo "false")
SECURITY_AVAILABLE := $(shell test -f $(SECURITY_CLEANUP) && echo "true" || echo "false")

##@ 🚀 Session Management
.PHONY: session-start session-end session-status session-history

session-start: ## 🟢 Iniciar nova sessão de desenvolvimento
	@echo -e "$(GREEN)🚀 Iniciando sessão de desenvolvimento...$(NC)"
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(SESSION_MANAGER) start --type development --user "$(USER)"
else
	@echo -e "$(YELLOW)⚠️  Scripts de sessão não encontrados. Continuando sem tracking...$(NC)"
endif

session-end: ## 🔴 Finalizar sessão atual
	@echo -e "$(RED)🔴 Finalizando sessão...$(NC)"
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(SESSION_MANAGER) end
else
	@echo -e "$(YELLOW)⚠️  Scripts de sessão não encontrados$(NC)"
endif

session-status: ## 📊 Mostrar status da sessão atual
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(SESSION_MANAGER) status
else
	@echo -e "$(YELLOW)⚠️  Scripts de sessão não encontrados$(NC)"
endif

session-history: ## 📋 Mostrar histórico de sessões
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(SESSION_MANAGER) history --limit 10
else
	@echo -e "$(YELLOW)⚠️  Scripts de sessão não encontrados$(NC)"
endif

##@ 🔍 Language Detection & Project Creation
.PHONY: detect-language create-project analyze-structure

detect-language: ## 🔤 Detectar linguagem do projeto atual
	@echo -e "$(BLUE)🔍 Detectando linguagem do projeto...$(NC)"
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(LANGUAGE_DETECTOR) . --verbose
else
	@echo -e "$(YELLOW)⚠️  Script de detecção não encontrado$(NC)"
endif

detect-frameworks: ## 🚀 Detectar frameworks do projeto atual
	@echo -e "$(PURPLE)🚀 Detectando frameworks...$(NC)"
	@$(MAKE) _log ACTION_TYPE="detect_frameworks" DESCRIPTION="Detectando frameworks do projeto"
ifeq ($(FRAMEWORK_AVAILABLE),true)
	@python3 $(FRAMEWORK_DETECTOR) . --verbose
else
	@echo -e "$(YELLOW)⚠️  Framework detector não encontrado$(NC)"
endif

analyze-full: ## 🔬 Análise completa (linguagem + frameworks)
	@echo -e "$(CYAN)🔬 Executando análise completa...$(NC)"
	@$(MAKE) _log ACTION_TYPE="analyze_full" DESCRIPTION="Análise completa do projeto"
	@echo -e "$(BLUE)📋 Análise de Linguagem:$(NC)"
	@$(MAKE) detect-language
	@echo -e "$(PURPLE)📋 Análise de Frameworks:$(NC)"
	@$(MAKE) detect-frameworks

create-project: ## 🏗️  Criar novo projeto (uso: make create-project NAME=my-project LANG=python TYPE=api)
	@echo -e "$(PURPLE)🏗️  Criando novo projeto...$(NC)"
ifndef NAME
	@echo -e "$(RED)❌ Erro: NAME não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make create-project NAME=my-project [LANG=auto] [TYPE=api] [DEST=./]$(NC)"
	@exit 1
endif
	@$(PROJECT_CREATOR) "$(NAME)" "$(or $(LANG),auto)" "$(or $(TYPE),api)" "$(or $(DEST),.)"

analyze-structure: ## 📁 Analisar estrutura do projeto atual
	@echo -e "$(CYAN)📁 Analisando estrutura do projeto...$(NC)"
	@echo -e "$(BLUE)📋 Diretórios principais:$(NC)"
	@find . -maxdepth 2 -type d -not -path '*/.*' | head -20 | sed 's/^/  /'
	@echo -e "$(BLUE)📄 Arquivos de configuração:$(NC)"
	@find . -maxdepth 2 -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.cfg" -o -name "*.ini" | head -10 | sed 's/^/  /'

##@ 🔧 Development (Language Agnostic)
.PHONY: init dev build test clean install run

init: session-start detect-language ## 🎯 Inicializar ambiente de desenvolvimento
	@echo -e "$(GREEN)🎯 Inicializando ambiente...$(NC)"
	@$(MAKE) _log ACTION_TYPE="init" DESCRIPTION="Inicializando ambiente de desenvolvimento"
	@$(MAKE) _detect_and_init

dev: ## 🔄 Iniciar modo desenvolvimento com hot reload
	@echo -e "$(CYAN)🔄 Iniciando modo desenvolvimento...$(NC)"
	@$(MAKE) _log ACTION_TYPE="dev_start" DESCRIPTION="Iniciando modo desenvolvimento"
	@$(MAKE) _detect_and_dev

build: ## 🏗️  Compilar/build do projeto
	@echo -e "$(BLUE)🏗️  Executando build...$(NC)"
	@$(MAKE) _log ACTION_TYPE="build" DESCRIPTION="Executando build do projeto"
	@$(MAKE) _detect_and_build

test: ## 🧪 Executar testes
	@echo -e "$(PURPLE)🧪 Executando testes...$(NC)"
	@$(MAKE) _log ACTION_TYPE="test" DESCRIPTION="Executando testes"
	@$(MAKE) _detect_and_test

install: ## 📦 Instalar dependências
	@echo -e "$(GREEN)📦 Instalando dependências...$(NC)"
	@$(MAKE) _log ACTION_TYPE="install" DESCRIPTION="Instalando dependências"
	@$(MAKE) _detect_and_install

run: ## ▶️  Executar aplicação
	@echo -e "$(GREEN)▶️  Executando aplicação...$(NC)"
	@$(MAKE) _log ACTION_TYPE="run" DESCRIPTION="Executando aplicação"
	@$(MAKE) _detect_and_run

clean: ## 🧹 Limpar arquivos temporários
	@echo -e "$(YELLOW)🧹 Limpando arquivos temporários...$(NC)"
	@$(MAKE) _log ACTION_TYPE="clean" DESCRIPTION="Limpando arquivos temporários"
	@$(MAKE) _detect_and_clean

##@ � Version Management
.PHONY: version-backup version-restore version-list version-cleanup version-history

version-backup: ## 📦 Criar backup versionado (uso: make version-backup FILE=arquivo.txt)
	@echo -e "$(PURPLE)📦 Criando backup versionado...$(NC)"
	@$(MAKE) _log ACTION_TYPE="version_backup" DESCRIPTION="Backup versionado de $(FILE)"
ifndef FILE
	@echo -e "$(RED)❌ Erro: FILE não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make version-backup FILE=arquivo.txt$(NC)"
	@exit 1
endif
	@python3 ./scripts/version-manager.py backup "$(FILE)"

version-restore: ## 🔄 Restaurar versão específica (uso: make version-restore FILE=arquivo.txt VERSION=1)
	@echo -e "$(CYAN)🔄 Restaurando versão...$(NC)"
	@$(MAKE) _log ACTION_TYPE="version_restore" DESCRIPTION="Restaurando $(FILE) versão $(VERSION)"
ifndef FILE
	@echo -e "$(RED)❌ Erro: FILE não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make version-restore FILE=arquivo.txt VERSION=1$(NC)"
	@exit 1
endif
ifndef VERSION
	@echo -e "$(RED)❌ Erro: VERSION não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make version-restore FILE=arquivo.txt VERSION=1$(NC)"
	@exit 1
endif
	@python3 ./scripts/version-manager.py restore "$(FILE)" --version $(VERSION)

version-list: ## 📋 Listar versões disponíveis (uso: make version-list [FILE=arquivo.txt])
	@echo -e "$(BLUE)📋 Listando versões...$(NC)"
ifdef FILE
	@python3 ./scripts/version-manager.py list "$(FILE)"
else
	@python3 ./scripts/version-manager.py list
endif

version-cleanup: ## 🧹 Limpar versões antigas (uso: make version-cleanup FILE=arquivo.txt [KEEP=5])
	@echo -e "$(YELLOW)🧹 Limpando versões antigas...$(NC)"
	@$(MAKE) _log ACTION_TYPE="version_cleanup" DESCRIPTION="Limpeza de versões de $(FILE)"
ifndef FILE
	@echo -e "$(RED)❌ Erro: FILE não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make version-cleanup FILE=arquivo.txt [KEEP=5]$(NC)"
	@exit 1
endif
	@python3 ./scripts/version-manager.py cleanup "$(FILE)" --keep $(or $(KEEP),5)

version-history: ## 📊 Mostrar histórico de versões (uso: make version-history FILE=arquivo.txt)
	@echo -e "$(PURPLE)📊 Mostrando histórico...$(NC)"
ifndef FILE
	@echo -e "$(RED)❌ Erro: FILE não especificado$(NC)"
	@echo -e "$(CYAN)   Uso: make version-history FILE=arquivo.txt$(NC)"
	@exit 1
endif
	@python3 ./scripts/version-manager.py history "$(FILE)"

##@ �📋 Template Management
.PHONY: mcp-activate mcp-status generate-config template-test

mcp-activate: ## 🤖 Ativar contexto MCP
	@echo -e "$(PURPLE)🤖 Ativando contexto MCP...$(NC)"
	@$(MAKE) _log ACTION_TYPE="mcp_activate" DESCRIPTION="Ativando contexto MCP"
	@if [ -f "mcp-questions.yaml" ]; then \
		echo -e "$(GREEN)✅ Configuração MCP encontrada$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️  Configuração MCP não encontrada. Gerando...$(NC)"; \
		$(MAKE) generate-config; \
	fi

mcp-status: ## 📊 Verificar status do MCP
	@echo -e "$(BLUE)📊 Status do MCP:$(NC)"
	@if [ -f "mcp-questions.yaml" ]; then \
		echo -e "$(GREEN)  ✅ mcp-questions.yaml presente$(NC)"; \
	else \
		echo -e "$(RED)  ❌ mcp-questions.yaml ausente$(NC)"; \
	fi
	@if [ -f "objetivo.yaml" ]; then \
		echo -e "$(GREEN)  ✅ objetivo.yaml presente$(NC)"; \
	else \
		echo -e "$(RED)  ❌ objetivo.yaml ausente$(NC)"; \
	fi

generate-config: ## ⚙️  Gerar configuração MCP baseada no objetivo.yaml
	@echo -e "$(CYAN)⚙️  Gerando configuração MCP...$(NC)"
	@$(MAKE) _log ACTION_TYPE="generate_config" DESCRIPTION="Gerando configuração MCP"
	@if [ -f "objetivo.yaml" ]; then \
		echo -e "$(GREEN)✅ objetivo.yaml encontrado. Gerando mcp-questions.yaml...$(NC)"; \
		echo "# Auto-generated MCP configuration" > mcp-questions.yaml; \
		echo "# Based on objetivo.yaml" >> mcp-questions.yaml; \
		date >> mcp-questions.yaml; \
	else \
		echo -e "$(RED)❌ objetivo.yaml não encontrado$(NC)"; \
	fi

template-test: ## 🧪 Testar sistema de templates
	@echo -e "$(PURPLE)🧪 Testando sistema de templates...$(NC)"
	@$(MAKE) _log ACTION_TYPE="template_test" DESCRIPTION="Testando sistema de templates"
	@echo -e "$(BLUE)📋 Estrutura de templates:$(NC)"
	@find templates/ -type f 2>/dev/null | head -20 | sed 's/^/  /' || echo -e "$(YELLOW)  ⚠️  Pasta templates/ não encontrada$(NC)"
	@echo -e "$(CYAN)📊 Estatísticas de templates:$(NC)"
	@echo -e "$(GREEN)  Python templates: $(shell find templates/language-specific/python/ -name "*.template.*" 2>/dev/null | wc -l)$(NC)"
	@echo -e "$(GREEN)  JavaScript templates: $(shell find templates/language-specific/javascript/ -name "*.template.*" 2>/dev/null | wc -l)$(NC)"
	@echo -e "$(GREEN)  Base templates: $(shell find templates/base-structure/ -name "*.template.*" 2>/dev/null | wc -l)$(NC)"

template-validate: ## ✅ Validar templates por linguagem (uso: make template-validate LANG=python)
	@echo -e "$(BLUE)✅ Validando templates...$(NC)"
	@$(MAKE) _log ACTION_TYPE="template_validate" DESCRIPTION="Validando templates $(LANG)"
ifdef LANG
	@echo -e "$(CYAN)🔍 Validando templates para: $(LANG)$(NC)"
	@find templates/language-specific/$(LANG)/ -name "*.template.*" 2>/dev/null || echo -e "$(RED)❌ Templates para $(LANG) não encontrados$(NC)"
else
	@echo -e "$(YELLOW)⚠️  Especifique a linguagem: make template-validate LANG=python$(NC)"
	@echo -e "$(BLUE)📋 Linguagens disponíveis:$(NC)"
	@find templates/language-specific/ -maxdepth 1 -type d | grep -v "/$$" | sed 's|templates/language-specific/||' | sed 's/^/  /'
endif

##@ 🤖 AI & GitHub Copilot Integration
.PHONY: copilot-setup copilot-config copilot-test ai-optimize

copilot-setup: ## 🚀 Configurar GitHub Copilot e VS Code
	@echo -e "$(PURPLE)🤖 Configurando GitHub Copilot...$(NC)"
	@$(MAKE) _log ACTION_TYPE="copilot_setup" DESCRIPTION="Configurando integração com GitHub Copilot"
ifeq ($(COPILOT_AVAILABLE),true)
	@bash $(COPILOT_SETUP)
else
	@echo -e "$(RED)❌ Script copilot-setup.sh não encontrado$(NC)"
	@echo -e "$(YELLOW)⚠️  Executando configuração básica...$(NC)"
	@mkdir -p .vscode
	@if [ ! -f .vscode/extensions.json ]; then \
		echo -e "$(BLUE)📦 Criando extensions.json...$(NC)"; \
		cp templates/.vscode/extensions.template.json .vscode/extensions.json 2>/dev/null || echo -e "$(YELLOW)⚠️  Template extensions.json não encontrado$(NC)"; \
	fi
	@echo -e "$(GREEN)✅ Configuração básica concluída$(NC)"
endif

copilot-config: detect-language ## ⚙️  Configurar Copilot para linguagem específica
	@echo -e "$(PURPLE)⚙️  Configurando Copilot para linguagem detectada...$(NC)"
	@$(MAKE) _log ACTION_TYPE="copilot_config" DESCRIPTION="Configurando Copilot para linguagem específica"
	@DETECTED_LANG=$$(python3 $(LANGUAGE_DETECTOR) 2>/dev/null | grep "Primary:" | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]'); \
	if [ -n "$$DETECTED_LANG" ]; then \
		echo -e "$(CYAN)🎯 Configurando para: $$DETECTED_LANG$(NC)"; \
		if [ -f "templates/.vscode/settings.$$DETECTED_LANG.json" ]; then \
			cp "templates/.vscode/settings.$$DETECTED_LANG.json" .vscode/settings.json; \
			echo -e "$(GREEN)✅ Configuração específica aplicada$(NC)"; \
		else \
			echo -e "$(YELLOW)⚠️  Configuração específica não encontrada, usando padrão$(NC)"; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Linguagem não detectada$(NC)"; \
	fi

copilot-test: ## 🧪 Testar integração do Copilot
	@echo -e "$(PURPLE)🧪 Testando integração do GitHub Copilot...$(NC)"
	@$(MAKE) _log ACTION_TYPE="copilot_test" DESCRIPTION="Testando integração do Copilot"
	@echo -e "$(CYAN)🔍 Verificando arquivos de configuração:$(NC)"
	@test -f .vscode/extensions.json && echo -e "$(GREEN)  ✅ extensions.json$(NC)" || echo -e "$(RED)  ❌ extensions.json$(NC)"
	@test -f .vscode/settings.json && echo -e "$(GREEN)  ✅ settings.json$(NC)" || echo -e "$(RED)  ❌ settings.json$(NC)"
	@test -f .vscode/workspace.code-workspace && echo -e "$(GREEN)  ✅ workspace.code-workspace$(NC)" || echo -e "$(YELLOW)  ⚠️  workspace.code-workspace (opcional)$(NC)"
	@echo -e "$(CYAN)📋 Extensions recomendadas instaladas no VS Code:$(NC)"
	@code --list-extensions 2>/dev/null | grep -E "(github\.copilot|ms-python\.python|ms-vscode\.vscode-typescript-next)" | sed 's/^/  ✅ /' || echo -e "$(YELLOW)  ⚠️  Execute VS Code para verificar extensions$(NC)"

ai-optimize: detect-language detect-frameworks ## 🎯 Otimizar projeto para AI (baseado em linguagem/framework)
	@echo -e "$(PURPLE)🎯 Otimizando projeto para desenvolvimento assistido por AI...$(NC)"
	@$(MAKE) _log ACTION_TYPE="ai_optimize" DESCRIPTION="Otimizando projeto para AI"
	@DETECTED_LANG=$$(python3 $(LANGUAGE_DETECTOR) 2>/dev/null | grep "Primary:" | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]'); \
	DETECTED_FRAMEWORK=$$(python3 $(FRAMEWORK_DETECTOR) --format json 2>/dev/null | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('frameworks', [{}])[0].get('name', '').lower() if data.get('frameworks') else '')" 2>/dev/null); \
	echo -e "$(CYAN)🔍 Linguagem: $$DETECTED_LANG$(NC)"; \
	echo -e "$(CYAN)🔍 Framework: $$DETECTED_FRAMEWORK$(NC)"; \
	echo -e "$(BLUE)🚀 Aplicando otimizações...$(NC)"; \
	if [ "$$DETECTED_LANG" = "python" ]; then \
		echo -e "$(GREEN)  🐍 Python: Configurando Pylance, Black, pytest$(NC)"; \
		if [ "$$DETECTED_FRAMEWORK" = "django" ]; then \
			echo -e "$(GREEN)  🎸 Django: Adicionando configurações específicas$(NC)"; \
		elif [ "$$DETECTED_FRAMEWORK" = "fastapi" ]; then \
			echo -e "$(GREEN)  ⚡ FastAPI: Adicionando configurações específicas$(NC)"; \
		fi; \
	elif [ "$$DETECTED_LANG" = "javascript" ] || [ "$$DETECTED_LANG" = "typescript" ]; then \
		echo -e "$(GREEN)  📜 JavaScript/TypeScript: Configurando ESLint, Prettier$(NC)"; \
		if [ "$$DETECTED_FRAMEWORK" = "react" ]; then \
			echo -e "$(GREEN)  ⚛️  React: Adicionando configurações específicas$(NC)"; \
		elif [ "$$DETECTED_FRAMEWORK" = "nextjs" ]; then \
			echo -e "$(GREEN)  🔺 Next.js: Adicionando configurações específicas$(NC)"; \
		fi; \
	fi; \
	echo -e "$(GREEN)✅ Otimização concluída! Reinicie o VS Code para aplicar$(NC)"

##@ � Security & Cleanup
.PHONY: security-cleanup security-scan security-validate

security-cleanup: ## 🚨 Remover arquivos sensíveis e secrets vazados
	@echo -e "$(RED)🚨 Executando limpeza de segurança...$(NC)"
	@$(MAKE) _log ACTION_TYPE="security_cleanup" DESCRIPTION="Removendo arquivos sensíveis e secrets"
ifeq ($(SECURITY_AVAILABLE),true)
	@bash $(SECURITY_CLEANUP)
else
	@echo -e "$(RED)❌ Script security-cleanup.sh não encontrado$(NC)"
	@echo -e "$(YELLOW)⚠️  Execute manualmente: rm -rf .ai-template/ .session-current$(NC)"
endif

security-scan: ## 🔍 Escanear projeto em busca de secrets vazados
	@echo -e "$(BLUE)🔍 Escaneando secrets vazados...$(NC)"
	@$(MAKE) _log ACTION_TYPE="security_scan" DESCRIPTION="Escaneando projeto para secrets"
	@echo -e "$(CYAN)🔍 Procurando UUIDs suspeitos...$(NC)"
	@find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.txt" -o -name "*.py" \) \
		-not -path "./.git/*" -not -path "./.venv/*" \
		-exec grep -l "[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}" {} \; 2>/dev/null | head -10 || echo -e "$(GREEN)✅ Nenhum UUID suspeito encontrado$(NC)"
	@echo -e "$(CYAN)🔍 Verificando arquivos .env...$(NC)"
	@find . -name ".env*" -type f 2>/dev/null | head -5 | sed 's/^/  ⚠️  /' || echo -e "$(GREEN)✅ Nenhum arquivo .env encontrado$(NC)"
	@echo -e "$(CYAN)🔍 Verificando arquivos de sessão...$(NC)"
	@find . -name "*.session*" -o -name ".session-*" -type f 2>/dev/null | head -5 | sed 's/^/  🚨 /' || echo -e "$(GREEN)✅ Nenhum arquivo de sessão encontrado$(NC)"

security-validate: ## ✅ Validar configurações de segurança
	@echo -e "$(PURPLE)✅ Validando segurança do projeto...$(NC)"
	@$(MAKE) _log ACTION_TYPE="security_validate" DESCRIPTION="Validando configurações de segurança"
	@echo -e "$(CYAN)📋 Verificando .gitignore...$(NC)"
	@if [ -f .gitignore ]; then \
		echo -e "$(GREEN)✅ .gitignore existe$(NC)"; \
		for rule in ".ai-template/" ".session-current" "*.session" ".env" "*.key"; do \
			if grep -q "$$rule" .gitignore; then \
				echo -e "$(GREEN)  ✅ $$rule protegido$(NC)"; \
			else \
				echo -e "$(RED)  ❌ $$rule NÃO protegido$(NC)"; \
			fi; \
		done; \
	else \
		echo -e "$(RED)❌ .gitignore não existe$(NC)"; \
	fi
	@echo -e "$(CYAN)🔐 Verificando diretórios sensíveis...$(NC)"
	@if [ -d .ai-template ]; then echo -e "$(RED)  🚨 .ai-template/ existe (REMOVER)$(NC)"; else echo -e "$(GREEN)  ✅ .ai-template/ não existe$(NC)"; fi
	@if [ -d .sessions ]; then echo -e "$(RED)  🚨 .sessions/ existe (REMOVER)$(NC)"; else echo -e "$(GREEN)  ✅ .sessions/ não existe$(NC)"; fi
	@if [ -f .session-current ]; then echo -e "$(RED)  🚨 .session-current existe (REMOVER)$(NC)"; else echo -e "$(GREEN)  ✅ .session-current não existe$(NC)"; fi
	@echo -e "$(GREEN)✅ Validação de segurança concluída$(NC)"

##@ �📊 Information & Help
.PHONY: help info status doctor

help: ## 💡 Mostrar esta ajuda
	@echo -e "$(BLUE)╔══════════════════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(BLUE)║$(NC)               $(PURPLE)🤖 AI Project Template v2.0.0$(NC)               $(BLUE)║$(NC)"
	@echo -e "$(BLUE)║$(NC)                 $(CYAN)Makefile Universal$(NC)                     $(BLUE)║$(NC)"
	@echo -e "$(BLUE)╚══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "$(CYAN)Comandos disponíveis:$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

info: ## ℹ️  Mostrar informações do projeto
	@echo -e "$(BLUE)ℹ️  Informações do Projeto:$(NC)"
	@echo -e "$(CYAN)  📋 Nome: $(PROJECT_NAME)$(NC)"
	@echo -e "$(CYAN)  📁 Diretório: $(CURDIR)$(NC)"
	@echo -e "$(CYAN)  🔧 Scripts: $(SCRIPTS_AVAILABLE)$(NC)"
	@echo -e "$(CYAN)  👤 Usuário: $(USER)$(NC)"
	@echo -e "$(CYAN)  📅 Data: $(shell date)$(NC)"

status: session-status mcp-status ## 📊 Status completo do projeto

doctor: ## 🏥 Diagnóstico do ambiente
	@echo -e "$(BLUE)🏥 Diagnóstico do Ambiente:$(NC)"
	@echo -e "$(CYAN)  Sistema Operacional:$(NC)"
	@echo -e "    $(shell uname -s) $(shell uname -r)"
	@echo -e "$(CYAN)  Shell:$(NC)"
	@echo -e "    $(SHELL)"
	@echo -e "$(CYAN)  Python:$(NC)"
	@python3 --version 2>/dev/null || echo -e "    $(RED)❌ Python 3 não encontrado$(NC)"
	@echo -e "$(CYAN)  Git:$(NC)"
	@git --version 2>/dev/null || echo -e "    $(RED)❌ Git não encontrado$(NC)"
	@echo -e "$(CYAN)  Scripts do Template:$(NC)"
	@test -f $(SESSION_MANAGER) && echo -e "    $(GREEN)✅ session-manager.py$(NC)" || echo -e "    $(RED)❌ session-manager.py$(NC)"
	@test -f $(LANGUAGE_DETECTOR) && echo -e "    $(GREEN)✅ detect-language.py$(NC)" || echo -e "    $(RED)❌ detect-language.py$(NC)"
	@test -f $(PROJECT_CREATOR) && echo -e "    $(GREEN)✅ create-project.sh$(NC)" || echo -e "    $(RED)❌ create-project.sh$(NC)"
	@test -f $(VERSION_MANAGER) && echo -e "    $(GREEN)✅ version-manager.py$(NC)" || echo -e "    $(RED)❌ version-manager.py$(NC)"
	@test -f $(FRAMEWORK_DETECTOR) && echo -e "    $(GREEN)✅ framework-detector.py$(NC)" || echo -e "    $(RED)❌ framework-detector.py$(NC)"
	@test -f $(COPILOT_SETUP) && echo -e "    $(GREEN)✅ copilot-setup.sh$(NC)" || echo -e "    $(RED)❌ copilot-setup.sh$(NC)"
	@test -f $(SECURITY_CLEANUP) && echo -e "    $(GREEN)✅ security-cleanup.sh$(NC)" || echo -e "    $(RED)❌ security-cleanup.sh$(NC)"

##@ 🔧 Internal Functions (Language Detection)
.PHONY: _detect_and_init _detect_and_dev _detect_and_build _detect_and_test _detect_and_install _detect_and_run _detect_and_clean _log

# Função para log de ações na sessão
_log:
ifeq ($(SCRIPTS_AVAILABLE),true)
	@python3 $(SESSION_MANAGER) log "$(ACTION_TYPE)" "$(DESCRIPTION)" --status completed 2>/dev/null || true
endif

# Detecção e execução por linguagem
_detect_and_init:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="init"

_detect_and_dev:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="dev"

_detect_and_build:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="build"

_detect_and_test:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="test"

_detect_and_install:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="install"

_detect_and_run:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="run"

_detect_and_clean:
	@$(MAKE) _detect_language_simple
	@$(MAKE) _execute_by_language TARGET="clean"

# Detecção de linguagem simplificada
_detect_language_simple:
	@if [ -f "package.json" ]; then \
		echo -e "$(GREEN)🔤 Linguagem detectada: JavaScript/Node.js$(NC)"; \
		$(eval DETECTED_LANG := javascript) \
	elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then \
		echo -e "$(GREEN)🔤 Linguagem detectada: Python$(NC)"; \
		$(eval DETECTED_LANG := python) \
	elif [ -f "go.mod" ]; then \
		echo -e "$(GREEN)🔤 Linguagem detectada: Go$(NC)"; \
		$(eval DETECTED_LANG := go) \
	elif [ -f "Cargo.toml" ]; then \
		echo -e "$(GREEN)🔤 Linguagem detectada: Rust$(NC)"; \
		$(eval DETECTED_LANG := rust) \
	elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then \
		echo -e "$(GREEN)🔤 Linguagem detectada: Java$(NC)"; \
		$(eval DETECTED_LANG := java) \
	else \
		echo -e "$(YELLOW)🔤 Linguagem não detectada. Usando genérico...$(NC)"; \
		$(eval DETECTED_LANG := generic) \
	fi

# Execução baseada na linguagem detectada
_execute_by_language:
ifeq ($(DETECTED_LANG),python)
	@$(MAKE) _python_$(TARGET)
else ifeq ($(DETECTED_LANG),javascript)
	@$(MAKE) _javascript_$(TARGET)
else ifeq ($(DETECTED_LANG),go)
	@$(MAKE) _go_$(TARGET)
else ifeq ($(DETECTED_LANG),rust)
	@$(MAKE) _rust_$(TARGET)
else ifeq ($(DETECTED_LANG),java)
	@$(MAKE) _java_$(TARGET)
else
	@$(MAKE) _generic_$(TARGET)
endif

# Comandos específicos por linguagem - Python
_python_init:
	@echo -e "$(GREEN)🐍 Configurando ambiente Python...$(NC)"
	@test -f requirements.txt && pip install -r requirements.txt || echo -e "$(YELLOW)⚠️  requirements.txt não encontrado$(NC)"
	@test -f setup.py && pip install -e . || true

_python_dev:
	@echo -e "$(CYAN)🐍 Iniciando desenvolvimento Python...$(NC)"
	@if command -v uvicorn >/dev/null 2>&1 && find . -name "*.py" -exec grep -l "FastAPI\|fastapi" {} \; | head -1 >/dev/null; then \
		echo -e "$(GREEN)🚀 Detectado FastAPI. Iniciando servidor...$(NC)"; \
		uvicorn main:app --reload --host 0.0.0.0 --port 8000; \
	elif find . -name "manage.py" >/dev/null 2>&1; then \
		echo -e "$(GREEN)🚀 Detectado Django. Iniciando servidor...$(NC)"; \
		python manage.py runserver; \
	else \
		echo -e "$(BLUE)🐍 Executando aplicação Python...$(NC)"; \
		python main.py 2>/dev/null || python app.py 2>/dev/null || echo -e "$(YELLOW)⚠️  Arquivo principal não encontrado$(NC)"; \
	fi

_python_build:
	@echo -e "$(BLUE)🐍 Build Python...$(NC)"
	@test -f setup.py && python setup.py build || echo -e "$(YELLOW)⚠️  Setup.py não encontrado$(NC)"

_python_test:
	@echo -e "$(PURPLE)🐍 Executando testes Python...$(NC)"
	@if command -v pytest >/dev/null 2>&1; then \
		pytest -v; \
	else \
		python -m unittest discover -v; \
	fi

_python_install:
	@$(MAKE) _python_init

_python_run:
	@echo -e "$(GREEN)🐍 Executando aplicação Python...$(NC)"
	@python main.py 2>/dev/null || python app.py 2>/dev/null || echo -e "$(RED)❌ Arquivo principal não encontrado$(NC)"

_python_clean:
	@echo -e "$(YELLOW)🐍 Limpando arquivos Python...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage 2>/dev/null || true

# Comandos específicos por linguagem - JavaScript/Node.js
_javascript_init:
	@echo -e "$(GREEN)📦 Configurando ambiente Node.js...$(NC)"
	@npm install

_javascript_dev:
	@echo -e "$(CYAN)📦 Iniciando desenvolvimento Node.js...$(NC)"
	@npm run dev 2>/dev/null || npm start 2>/dev/null || node index.js 2>/dev/null || echo -e "$(YELLOW)⚠️  Script de desenvolvimento não encontrado$(NC)"

_javascript_build:
	@echo -e "$(BLUE)📦 Build Node.js...$(NC)"
	@npm run build

_javascript_test:
	@echo -e "$(PURPLE)📦 Executando testes Node.js...$(NC)"
	@npm test

_javascript_install:
	@$(MAKE) _javascript_init

_javascript_run:
	@echo -e "$(GREEN)📦 Executando aplicação Node.js...$(NC)"
	@npm start 2>/dev/null || node index.js 2>/dev/null || node app.js 2>/dev/null || echo -e "$(RED)❌ Script de execução não encontrado$(NC)"

_javascript_clean:
	@echo -e "$(YELLOW)📦 Limpando arquivos Node.js...$(NC)"
	@rm -rf node_modules/ dist/ build/ .next/ coverage/ 2>/dev/null || true

# Comandos específicos por linguagem - Go
_go_init:
	@echo -e "$(GREEN)🔷 Configurando ambiente Go...$(NC)"
	@go mod tidy

_go_dev:
	@echo -e "$(CYAN)🔷 Iniciando desenvolvimento Go...$(NC)"
	@if command -v air >/dev/null 2>&1; then \
		air; \
	else \
		go run .; \
	fi

_go_build:
	@echo -e "$(BLUE)🔷 Build Go...$(NC)"
	@go build -o bin/$(PROJECT_NAME) .

_go_test:
	@echo -e "$(PURPLE)🔷 Executando testes Go...$(NC)"
	@go test -v ./...

_go_install:
	@$(MAKE) _go_init

_go_run:
	@echo -e "$(GREEN)🔷 Executando aplicação Go...$(NC)"
	@go run .

_go_clean:
	@echo -e "$(YELLOW)🔷 Limpando arquivos Go...$(NC)"
	@go clean
	@rm -rf bin/ 2>/dev/null || true

# Comandos específicos por linguagem - Rust
_rust_init:
	@echo -e "$(GREEN)🦀 Configurando ambiente Rust...$(NC)"
	@cargo check

_rust_dev:
	@echo -e "$(CYAN)🦀 Iniciando desenvolvimento Rust...$(NC)"
	@if command -v cargo-watch >/dev/null 2>&1; then \
		cargo watch -x run; \
	else \
		cargo run; \
	fi

_rust_build:
	@echo -e "$(BLUE)🦀 Build Rust...$(NC)"
	@cargo build --release

_rust_test:
	@echo -e "$(PURPLE)🦀 Executando testes Rust...$(NC)"
	@cargo test

_rust_install:
	@$(MAKE) _rust_init

_rust_run:
	@echo -e "$(GREEN)🦀 Executando aplicação Rust...$(NC)"
	@cargo run

_rust_clean:
	@echo -e "$(YELLOW)🦀 Limpando arquivos Rust...$(NC)"
	@cargo clean

# Comandos específicos por linguagem - Java
_java_init:
	@echo -e "$(GREEN)☕ Configurando ambiente Java...$(NC)"
	@if [ -f "pom.xml" ]; then \
		mvn clean compile; \
	elif [ -f "build.gradle" ]; then \
		./gradlew build; \
	fi

_java_dev:
	@echo -e "$(CYAN)☕ Iniciando desenvolvimento Java...$(NC)"
	@if [ -f "pom.xml" ]; then \
		mvn spring-boot:run 2>/dev/null || mvn exec:java 2>/dev/null || echo -e "$(YELLOW)⚠️  Plugin de execução não configurado$(NC)"; \
	elif [ -f "build.gradle" ]; then \
		./gradlew bootRun 2>/dev/null || ./gradlew run 2>/dev/null || echo -e "$(YELLOW)⚠️  Task de execução não configurada$(NC)"; \
	fi

_java_build:
	@echo -e "$(BLUE)☕ Build Java...$(NC)"
	@if [ -f "pom.xml" ]; then \
		mvn clean package; \
	elif [ -f "build.gradle" ]; then \
		./gradlew build; \
	fi

_java_test:
	@echo -e "$(PURPLE)☕ Executando testes Java...$(NC)"
	@if [ -f "pom.xml" ]; then \
		mvn test; \
	elif [ -f "build.gradle" ]; then \
		./gradlew test; \
	fi

_java_install:
	@$(MAKE) _java_init

_java_run:
	@echo -e "$(GREEN)☕ Executando aplicação Java...$(NC)"
	@$(MAKE) _java_dev

_java_clean:
	@echo -e "$(YELLOW)☕ Limpando arquivos Java...$(NC)"
	@if [ -f "pom.xml" ]; then \
		mvn clean; \
	elif [ -f "build.gradle" ]; then \
		./gradlew clean; \
	fi

# Comandos genéricos (fallback)
_generic_init:
	@echo -e "$(BLUE)⚙️  Inicialização genérica...$(NC)"
	@echo -e "$(YELLOW)ℹ️  Nenhuma linguagem específica detectada$(NC)"

_generic_dev:
	@echo -e "$(BLUE)⚙️  Modo desenvolvimento genérico...$(NC)"
	@echo -e "$(YELLOW)ℹ️  Configure um script de desenvolvimento específico$(NC)"

_generic_build:
	@echo -e "$(BLUE)⚙️  Build genérico...$(NC)"
	@echo -e "$(YELLOW)ℹ️  Configure um script de build específico$(NC)"

_generic_test:
	@echo -e "$(BLUE)⚙️  Testes genéricos...$(NC)"
	@echo -e "$(YELLOW)ℹ️  Configure um script de teste específico$(NC)"

_generic_install:
	@$(MAKE) _generic_init

_generic_run:
	@echo -e "$(BLUE)⚙️  Execução genérica...$(NC)"
	@echo -e "$(YELLOW)ℹ️  Configure um script de execução específico$(NC)"

_generic_clean:
	@echo -e "$(BLUE)⚙️  Limpeza genérica...$(NC)"
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true