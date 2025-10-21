#!/usr/bin/env bash
#
# AI Project Template - Script de Criação de Projetos
# Gera novos projetos baseados no template agnóstico
# Uso: ./create-project.sh <nome-do-projeto> [linguagem] [tipo] [destino]
#

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configurações
TEMPLATE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME=$(basename "$0")
VERSION="1.0.0"

# Funções
show_banner() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                ${PURPLE}🤖 AI Project Template v${VERSION}${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}              ${CYAN}Gerador Universal de Projetos${NC}                ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    echo -e "${YELLOW}Uso:${NC}"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC} ${CYAN}<nome-do-projeto>${NC} [${YELLOW}linguagem${NC}] [${YELLOW}tipo${NC}] [${YELLOW}destino${NC}]"
    echo ""
    echo -e "${YELLOW}Argumentos:${NC}"
    echo -e "  ${CYAN}nome-do-projeto${NC}    Nome do projeto (obrigatório)"
    echo -e "  ${YELLOW}linguagem${NC}          Linguagem: python, javascript, go, rust, auto (padrão: auto)"
    echo -e "  ${YELLOW}tipo${NC}               Tipo: api, cli, webapp, library (padrão: api)"
    echo -e "  ${YELLOW}destino${NC}            Diretório destino (padrão: diretório atual)"
    echo ""
    echo -e "${YELLOW}Exemplos:${NC}"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC} my-api python api ./projects"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC} my-cli go cli"
    echo -e "  ${GREEN}$SCRIPT_NAME${NC} my-webapp auto webapp"
    echo ""
    echo -e "${YELLOW}Linguagens suportadas:${NC} python, javascript, typescript, go, rust, java, csharp"
    echo -e "${YELLOW}Tipos suportados:${NC} api, cli, webapp, library"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

validate_inputs() {
    # Validar nome do projeto
    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Nome do projeto deve conter apenas letras, números, hífens e underscores"
        return 1
    fi
    
    # Validar linguagem
    case "$LANGUAGE" in
        python|javascript|typescript|go|rust|java|csharp|auto)
            log_success "Linguagem: $LANGUAGE"
            ;;
        *)
            log_error "Linguagem '$LANGUAGE' não suportada"
            log_info "Linguagens disponíveis: python, javascript, typescript, go, rust, java, csharp, auto"
            return 1
            ;;
    esac
    
    # Validar tipo
    case "$PROJECT_TYPE" in
        api|cli|webapp|library)
            log_success "Tipo: $PROJECT_TYPE"
            ;;
        *)
            log_error "Tipo '$PROJECT_TYPE' não suportado"
            log_info "Tipos disponíveis: api, cli, webapp, library"
            return 1
            ;;
    esac
    
    # Verificar se destino existe
    if [ ! -d "$DESTINATION" ]; then
        log_warning "Diretório destino '$DESTINATION' não existe. Criando..."
        mkdir -p "$DESTINATION" || {
            log_error "Falha ao criar diretório destino"
            return 1
        }
    fi
    
    return 0
}

detect_language() {
    if [ "$LANGUAGE" != "auto" ]; then
        return 0
    fi
    
    log_info "Executando detecção automática de linguagem..."
    
    # Usar o sistema de detecção Python se disponível
    local detect_script="$TEMPLATE_PATH/scripts/detect-language.py"
    
    if [ -f "$detect_script" ] && command -v python3 >/dev/null 2>&1; then
        local detection_result
        detection_result=$(python3 "$detect_script" "$DESTINATION" --output json 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$detection_result" ]; then
            # Extrair linguagem do JSON usando grep/sed
            LANGUAGE=$(echo "$detection_result" | grep '"primary_language"' | sed 's/.*"primary_language": "\([^"]*\)".*/\1/')
            
            if [ -n "$LANGUAGE" ] && [ "$LANGUAGE" != "null" ]; then
                log_success "Linguagem detectada automaticamente: $LANGUAGE"
                
                # Extrair confiança
                local confidence
                confidence=$(echo "$detection_result" | grep '"confidence"' | sed 's/.*"confidence": \([0-9.]*\).*/\1/')
                if [ -n "$confidence" ]; then
                    local confidence_percent=$(echo "$confidence * 100" | bc 2>/dev/null || echo "N/A")
                    log_info "Confiança na detecção: ${confidence_percent}%"
                fi
                
                return 0
            fi
        fi
    fi
    
    # Fallback para detecção simples
    log_warning "Sistema avançado de detecção não disponível. Usando detecção básica..."
    
    # Detecção básica por arquivos
    if [ -f "$DESTINATION/package.json" ]; then
        LANGUAGE="javascript"
    elif [ -f "$DESTINATION/requirements.txt" ] || [ -f "$DESTINATION/setup.py" ] || [ -f "$DESTINATION/pyproject.toml" ]; then
        LANGUAGE="python"
    elif [ -f "$DESTINATION/go.mod" ]; then
        LANGUAGE="go"
    elif [ -f "$DESTINATION/Cargo.toml" ]; then
        LANGUAGE="rust"
    elif [ -f "$DESTINATION/pom.xml" ] || [ -f "$DESTINATION/build.gradle" ]; then
        LANGUAGE="java"
    elif [ -f "$DESTINATION"/*.csproj ] || [ -f "$DESTINATION"/*.sln ]; then
        LANGUAGE="csharp"
    else
        LANGUAGE="python"  # Default final
    fi
    
    log_success "Linguagem detectada: $LANGUAGE (detecção básica)"
}

copy_base_structure() {
    log_info "Copiando estrutura base..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    
    # Verificar se projeto já existe
    if [ -d "$project_path" ]; then
        log_error "Projeto '$PROJECT_NAME' já existe em '$DESTINATION'"
        return 1
    fi
    
    # Criar estrutura básica
    mkdir -p "$project_path"/{src,tests,docs,config,scripts,.vscode}
    
    # Copiar templates base
    if [ -d "$TEMPLATE_PATH/templates/base-structure" ]; then
        cp -r "$TEMPLATE_PATH/templates/base-structure"/* "$project_path/" 2>/dev/null || true
    fi
    
    log_success "Estrutura base copiada"
}

copy_language_templates() {
    log_info "Aplicando templates específicos para $LANGUAGE..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    local lang_templates="$TEMPLATE_PATH/templates/language-specific/$LANGUAGE"
    
    if [ -d "$lang_templates" ]; then
        cp -r "$lang_templates"/* "$project_path/" 2>/dev/null || true
        log_success "Templates de $LANGUAGE aplicados"
    else
        log_warning "Templates para $LANGUAGE não encontrados"
    fi
}

copy_project_type_templates() {
    log_info "Aplicando templates para tipo '$PROJECT_TYPE'..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    local type_templates="$TEMPLATE_PATH/templates/project-type/$PROJECT_TYPE"
    
    if [ -d "$type_templates" ]; then
        cp -r "$type_templates"/* "$project_path/" 2>/dev/null || true
        log_success "Templates de $PROJECT_TYPE aplicados"
    else
        log_warning "Templates para tipo $PROJECT_TYPE não encontrados"
    fi
}

process_templates() {
    log_info "Processando templates com placeholders..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    
    # Processar arquivos .template.*
    find "$project_path" -name "*.template.*" -type f | while read -r template_file; do
        local target_file="${template_file//.template/}"
        
        # Substituir placeholders básicos
        sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            -e "s/{{PROJECT_DESCRIPTION}}/Project generated by AI Project Template/g" \
            -e "s/{{AUTHOR_NAME}}/Developer/g" \
            -e "s/{{AUTHOR_EMAIL}}/developer@example.com/g" \
            -e "s/{{LICENSE}}/MIT/g" \
            -e "s/{{CREATION_DATE}}/$(date +%Y-%m-%d)/g" \
            -e "s/{{PROJECT_VERSION}}/0.1.0/g" \
            "$template_file" > "$target_file"
        
        # Remover arquivo template
        rm "$template_file"
        
        log_success "Processado: $(basename "$target_file")"
    done
}

generate_mcp_config() {
    log_info "Gerando configuração MCP..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    local mcp_file="$project_path/mcp-questions.yaml"
    
    # Gerar configuração MCP básica
    cat > "$mcp_file" << EOF
# Configuração MCP para $PROJECT_NAME
# Gerado automaticamente pelo AI Project Template

project_name: "$PROJECT_NAME"
project_type: "$PROJECT_TYPE"
language: "$LANGUAGE"
description: "Project generated by AI Project Template"
creation_date: "$(date +%Y-%m-%d)"

# Configurações específicas da linguagem
language_config:
  detected: "$LANGUAGE"
  auto_detected: $([ "$ORIGINAL_LANGUAGE" = "auto" ] && echo "true" || echo "false")

# MCP Integration
mcp_integration:
  context_name: "${PROJECT_NAME}-context"
  capabilities:
    - "Language-specific code completion"
    - "Project structure awareness"
    - "Framework-specific suggestions"
EOF
    
    log_success "Configuração MCP gerada"
}

create_workspace_config() {
    log_info "Criando configuração do workspace VS Code..."
    
    local project_path="$DESTINATION/$PROJECT_NAME"
    local workspace_file="$project_path/$PROJECT_NAME.code-workspace"
    
    cat > "$workspace_file" << EOF
{
    "folders": [
        {
            "path": "."
        }
    ],
    "settings": {
        "files.associations": {
            "*.yaml": "yaml",
            "*.yml": "yaml"
        },
        "editor.formatOnSave": true,
        "editor.insertSpaces": true,
        "editor.tabSize": 4
    },
    "extensions": {
        "recommendations": [
            "ms-vscode.vscode-json",
            "redhat.vscode-yaml",
            "github.copilot",
            "github.copilot-chat"
        ]
    }
}
EOF
    
    log_success "Workspace VS Code configurado"
}

show_next_steps() {
    local project_path="$DESTINATION/$PROJECT_NAME"
    
    echo ""
    echo -e "${GREEN}🎉 Projeto '$PROJECT_NAME' criado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📁 Localização:${NC} $project_path"
    echo -e "${YELLOW}🔧 Linguagem:${NC} $LANGUAGE"
    echo -e "${YELLOW}📦 Tipo:${NC} $PROJECT_TYPE"
    echo ""
    echo -e "${BLUE}🚀 Próximos passos:${NC}"
    echo -e "  1. ${CYAN}cd $project_path${NC}"
    echo -e "  2. ${CYAN}code $PROJECT_NAME.code-workspace${NC}"
    echo -e "  3. ${CYAN}make init${NC} (para configurar dependências)"
    echo -e "  4. ${CYAN}make dev${NC} (para iniciar desenvolvimento)"
    echo ""
    echo -e "${PURPLE}📖 Documentação:${NC} Veja README.md no projeto criado"
    echo ""
}

# Script principal
main() {
    show_banner
    
    # Verificar argumentos
    if [ $# -lt 1 ]; then
        log_error "Nome do projeto não especificado"
        echo ""
        show_usage
        exit 1
    fi
    
    # Processar argumentos
    PROJECT_NAME="$1"
    LANGUAGE="${2:-auto}"
    PROJECT_TYPE="${3:-api}"
    DESTINATION="${4:-$(pwd)}"
    
    # Salvar linguagem original para tracking
    ORIGINAL_LANGUAGE="$LANGUAGE"
    
    # Mostrar informações
    log_info "Criando projeto: $PROJECT_NAME"
    log_info "Linguagem: $LANGUAGE"
    log_info "Tipo: $PROJECT_TYPE"
    log_info "Destino: $DESTINATION"
    echo ""
    
    # Validações
    validate_inputs || exit 1
    
    # Detecção de linguagem
    detect_language
    
    # Criar projeto
    copy_base_structure || exit 1
    copy_language_templates
    copy_project_type_templates
    process_templates
    generate_mcp_config
    create_workspace_config
    
    # Finalizar
    show_next_steps
    
    log_success "Projeto criado em $(date +%H:%M:%S)"
}

# Verificar se é chamada direta
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi