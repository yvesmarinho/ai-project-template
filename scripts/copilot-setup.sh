#!/bin/bash
# GitHub Copilot Workspace Generator
# Gera workspace personalizado com base na linguagem e framework detectados

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$PROJECT_ROOT/templates/.vscode"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Função para detectar linguagem
detect_language() {
    if [[ -f "$PROJECT_ROOT/scripts/detect-language.py" ]]; then
        python3 "$PROJECT_ROOT/scripts/detect-language.py" 2>/dev/null | grep "Primary:" | cut -d' ' -f2 | tr '[:upper:]' '[:lower:]' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Função para detectar framework
detect_framework() {
    if [[ -f "$PROJECT_ROOT/scripts/framework-detector.py" ]]; then
        python3 "$PROJECT_ROOT/scripts/framework-detector.py" --format json 2>/dev/null | \
            python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('frameworks', [{}])[0].get('name', '').lower() if data.get('frameworks') else '')" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Função para processar templates
process_template() {
    local template_file="$1"
    local output_file="$2"
    local language="$3"
    local framework="$4"
    local project_name="$5"
    
    # Substituições básicas (sem Handlebars completo, apenas placeholders simples)
    sed -e "s/{{project_name}}/$project_name/g" \
        -e "s/{{language}}/$language/g" \
        -e "s/{{framework}}/$framework/g" \
        -e "s/{{python_path}}/python3/g" \
        -e "s/{{type_checking_mode}}/basic/g" \
        -e "s/{{copilot_secret}}/your-secret-here/g" \
        -e "s/{{locale}}/pt-BR/g" \
        -e "s/{{preferred_theme}}/Default Dark+/g" \
        "$template_file" > "$output_file"
}

# Função principal
main() {
    echo -e "${BLUE}🤖 GitHub Copilot Workspace Generator${NC}"
    echo -e "${CYAN}Configurando workspace otimizado para AI...${NC}"
    
    # Detectar contexto do projeto
    LANGUAGE=$(detect_language)
    FRAMEWORK=$(detect_framework)
    PROJECT_NAME=$(basename "$PWD")
    
    echo -e "${CYAN}🔍 Linguagem detectada: ${YELLOW}$LANGUAGE${NC}"
    echo -e "${CYAN}🔍 Framework detectado: ${YELLOW}$FRAMEWORK${NC}"
    echo -e "${CYAN}📋 Projeto: ${YELLOW}$PROJECT_NAME${NC}"
    
    # Criar diretório .vscode se não existir
    mkdir -p .vscode
    
    # Processar templates
    if [[ -f "$TEMPLATES_DIR/extensions.template.json" ]]; then
        echo -e "${BLUE}📦 Configurando extensions.json...${NC}"
        cp "$TEMPLATES_DIR/extensions.template.json" .vscode/extensions.json
        echo -e "${GREEN}✅ Extensions configuradas${NC}"
    fi
    
    if [[ -f "$TEMPLATES_DIR/settings.template.json" ]]; then
        echo -e "${BLUE}⚙️  Configurando settings.json...${NC}"
        # Para o settings.json, vamos usar apenas as configurações básicas
        cat > .vscode/settings.json << EOF
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": true,
    "markdown": true
  },
  "github.copilot.chat.enableCodeActions": true,
  "github.copilot.chat.enableInlineChat": true,
  "editor.inlineSuggest.enabled": true,
  "editor.suggestSelection": "first",
  "editor.tabCompletion": "on",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit",
    "source.fixAll": "explicit"
  }
}
EOF
        echo -e "${GREEN}✅ Settings básicos configurados${NC}"
    fi
    
    if [[ -f "$TEMPLATES_DIR/workspace.template.code-workspace" ]]; then
        echo -e "${BLUE}🗂️  Configurando workspace...${NC}"
        process_template "$TEMPLATES_DIR/workspace.template.code-workspace" \
                        "${PROJECT_NAME}.code-workspace" \
                        "$LANGUAGE" \
                        "$FRAMEWORK" \
                        "$PROJECT_NAME"
        echo -e "${GREEN}✅ Workspace configurado: ${PROJECT_NAME}.code-workspace${NC}"
    fi
    
    # Configurações específicas por linguagem
    case "$LANGUAGE" in
        "python")
            echo -e "${BLUE}🐍 Aplicando configurações Python...${NC}"
            # Adicionar configurações Python específicas ao settings.json
            python3 -c '
import json
try:
    with open(".vscode/settings.json", "r") as f:
        settings = json.load(f)
    
    python_settings = {
        "python.defaultInterpreterPath": "python3",
        "python.linting.enabled": True,
        "python.linting.pylintEnabled": True,
        "python.formatting.provider": "black",
        "python.languageServer": "Pylance",
        "python.analysis.autoImportCompletions": True,
        "python.analysis.typeCheckingMode": "basic"
    }
    
    settings.update(python_settings)
    
    with open(".vscode/settings.json", "w") as f:
        json.dump(settings, f, indent=2)
    
    print("✅ Configurações Python aplicadas")
except Exception as e:
    print(f"⚠️  Erro ao aplicar configurações Python: {e}")
'
            ;;
        "javascript"|"typescript")
            echo -e "${BLUE}📜 Aplicando configurações JavaScript/TypeScript...${NC}"
            python3 -c '
import json
try:
    with open(".vscode/settings.json", "r") as f:
        settings = json.load(f)
    
    js_settings = {
        "typescript.preferences.quoteStyle": "single",
        "javascript.preferences.quoteStyle": "single",
        "typescript.suggest.autoImports": True,
        "javascript.suggest.autoImports": True,
        "typescript.updateImportsOnFileMove.enabled": "always",
        "javascript.updateImportsOnFileMove.enabled": "always"
    }
    
    settings.update(js_settings)
    
    with open(".vscode/settings.json", "w") as f:
        json.dump(settings, f, indent=2)
    
    print("✅ Configurações JavaScript/TypeScript aplicadas")
except Exception as e:
    print(f"⚠️  Erro ao aplicar configurações JS/TS: {e}")
'
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🎉 Workspace GitHub Copilot configurado com sucesso!${NC}"
    echo -e "${CYAN}📋 Arquivos criados:${NC}"
    echo -e "${YELLOW}  • .vscode/extensions.json${NC}"
    echo -e "${YELLOW}  • .vscode/settings.json${NC}"
    echo -e "${YELLOW}  • ${PROJECT_NAME}.code-workspace${NC}"
    echo ""
    echo -e "${BLUE}🚀 Para usar:${NC}"
    echo -e "${CYAN}  1. Execute: ${YELLOW}code ${PROJECT_NAME}.code-workspace${NC}"
    echo -e "${CYAN}  2. Instale as extensões recomendadas${NC}"
    echo -e "${CYAN}  3. Faça login no GitHub Copilot${NC}"
    echo ""
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi