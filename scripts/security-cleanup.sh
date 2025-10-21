#!/bin/bash
# Security Cleanup Script - AI Project Template
# Remove arquivos sensíveis e secrets vazados

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${RED}🚨 AI Project Template - Security Cleanup${NC}"
echo -e "${YELLOW}Removendo arquivos sensíveis e secrets vazados...${NC}"
echo ""

# Função para remover arquivos sensíveis
cleanup_sensitive_files() {
    echo -e "${BLUE}1. 🗑️  Removendo arquivos de sessão...${NC}"
    
    # Remover diretórios de sessão sensíveis
    if [[ -d ".ai-template" ]]; then
        echo -e "${YELLOW}   Removendo .ai-template/ directory...${NC}"
        rm -rf .ai-template/
        echo -e "${GREEN}   ✅ .ai-template/ removido${NC}"
    fi
    
    if [[ -d ".sessions" ]]; then
        echo -e "${YELLOW}   Removendo .sessions/ directory...${NC}"
        rm -rf .sessions/
        echo -e "${GREEN}   ✅ .sessions/ removido${NC}"
    fi
    
    # Remover outros arquivos de sessão
    find . -name ".session-current" -type f -delete 2>/dev/null || true
    find . -name "*.session" -type f -delete 2>/dev/null || true
    echo -e "${GREEN}   ✅ Arquivos de sessão removidos${NC}"
}

# Função para limpar secrets em arquivos existentes
clean_secrets_in_files() {
    echo -e "${BLUE}2. 🔐 Limpando secrets em arquivos existentes...${NC}"
    
    # Procurar por UUIDs que podem ser secrets
    echo -e "${YELLOW}   Procurando UUIDs vazados...${NC}"
    
    # Patterns de secrets comuns
    UUID_PATTERN="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    
    # Procurar arquivos que podem conter secrets
    SECRET_FILES=$(find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.txt" -o -name "*.log" \) \
                  -not -path "./.git/*" \
                  -not -path "./node_modules/*" \
                  -not -path "./.venv/*" 2>/dev/null || true)
    
    if [[ -n "$SECRET_FILES" ]]; then
        echo "$SECRET_FILES" | while read -r file; do
            if [[ -f "$file" ]] && grep -q -E "$UUID_PATTERN" "$file" 2>/dev/null; then
                echo -e "${YELLOW}   ⚠️  Possível secret encontrado em: $file${NC}"
                # Não modifica automaticamente, apenas reporta
            fi
        done
    fi
    
    echo -e "${GREEN}   ✅ Verificação de secrets concluída${NC}"
}

# Função para validar .gitignore
validate_gitignore() {
    echo -e "${BLUE}3. 📋 Validando .gitignore...${NC}"
    
    if [[ -f ".gitignore" ]]; then
        # Verificar se regras de segurança estão presentes
        REQUIRED_RULES=(".ai-template/" ".session-current" "*.session" ".env" "*.key")
        
        for rule in "${REQUIRED_RULES[@]}"; do
            if grep -q "^$rule" .gitignore 2>/dev/null; then
                echo -e "${GREEN}   ✅ $rule protegido${NC}"
            else
                echo -e "${RED}   ❌ $rule NÃO protegido${NC}"
            fi
        done
    else
        echo -e "${RED}   ❌ .gitignore não existe${NC}"
    fi
}

# Função para gerar novo UUID seguro
generate_new_session_id() {
    echo -e "${BLUE}4. 🔄 Gerando nova sessão segura...${NC}"
    
    # Gerar novo UUID para sessão
    NEW_SESSION_ID=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])")
    
    echo -e "${GREEN}   ✅ Nova sessão ID: ${NEW_SESSION_ID}${NC}"
    echo -e "${CYAN}   📝 Use este ID para iniciar nova sessão limpa${NC}"
}

# Função para verificar git status
check_git_status() {
    echo -e "${BLUE}5. 🔍 Verificando status do Git...${NC}"
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Verificar se há arquivos sensíveis staged
        STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)
        
        if [[ -n "$STAGED_FILES" ]]; then
            echo -e "${YELLOW}   ⚠️  Arquivos staged para commit:${NC}"
            echo "$STAGED_FILES" | while read -r file; do
                if [[ "$file" == *".session"* ]] || [[ "$file" == *".ai-template"* ]]; then
                    echo -e "${RED}   🚨 PERIGO: $file contém dados sensíveis${NC}"
                else
                    echo -e "${CYAN}   📄 $file${NC}"
                fi
            done
        fi
        
        # Verificar se .gitignore está staged
        if echo "$STAGED_FILES" | grep -q "\.gitignore"; then
            echo -e "${GREEN}   ✅ .gitignore será commitado${NC}"
        else
            echo -e "${YELLOW}   ⚠️  .gitignore não está staged${NC}"
            echo -e "${CYAN}   💡 Execute: git add .gitignore${NC}"
        fi
        
    else
        echo -e "${YELLOW}   ⚠️  Não é um repositório Git${NC}"
    fi
}

# Função principal
main() {
    echo -e "${CYAN}🚀 Iniciando limpeza de segurança...${NC}"
    echo ""
    
    cleanup_sensitive_files
    echo ""
    
    clean_secrets_in_files  
    echo ""
    
    validate_gitignore
    echo ""
    
    generate_new_session_id
    echo ""
    
    check_git_status
    echo ""
    
    echo -e "${GREEN}🎉 Limpeza de segurança concluída!${NC}"
    echo ""
    echo -e "${CYAN}📋 Próximos passos recomendados:${NC}"
    echo -e "${YELLOW}1. git add .gitignore${NC}"
    echo -e "${YELLOW}2. git commit -m 'security: Add .gitignore and remove sensitive files'${NC}" 
    echo -e "${YELLOW}3. git push${NC}"
    echo ""
    echo -e "${BLUE}💡 Para iniciar nova sessão segura:${NC}"
    echo -e "${CYAN}make session-start${NC}"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi