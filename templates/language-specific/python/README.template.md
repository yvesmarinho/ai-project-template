# {{project_name}}

{{description}}

## 🐍 Python Project Template

Este projeto foi criado usando o **AI Project Template** com configurações otimizadas para Python.

## 📋 Informações do Projeto

- **Linguagem**: Python {{python_version}}
- **Framework**: {{framework}}
- **Tipo**: {{project_type}}
- **Criado em**: {{creation_date}}

## 🚀 Quick Start

### Pré-requisitos

- Python {{python_version}} ou superior
- pip (gerenciador de pacotes Python)

### Instalação

```bash
# Clonar o repositório
git clone {{repository_url}}
cd {{project_name}}

# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt
```

### Execução

```bash
# Desenvolvimento
make dev

# Produção
make run

# Testes
make test
```

## 📁 Estrutura do Projeto

```
{{project_name}}/
├── src/                    # Código fonte principal
│   ├── {{package_name}}/
│   │   ├── __init__.py
│   │   ├── main.py        # Ponto de entrada
│   │   ├── config/        # Configurações
│   │   ├── models/        # Modelos de dados
│   │   ├── services/      # Lógica de negócio
│   │   └── utils/         # Utilitários
├── tests/                 # Testes automatizados
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── docs/                  # Documentação
├── scripts/               # Scripts de automação
├── requirements.txt       # Dependências de produção
├── requirements-dev.txt   # Dependências de desenvolvimento
├── pyproject.toml         # Configuração do projeto
├── pytest.ini            # Configuração do pytest
└── README.md
```

## 🔧 Desenvolvimento

### Ambiente Virtual

Sempre ative o ambiente virtual antes de trabalhar:

```bash
source venv/bin/activate
```

### Instalação para Desenvolvimento

```bash
# Instalar em modo desenvolvimento
pip install -e .

# Instalar dependências de desenvolvimento
pip install -r requirements-dev.txt
```

### Testes

```bash
# Executar todos os testes
pytest

# Executar com cobertura
pytest --cov=src

# Executar testes específicos
pytest tests/unit/test_main.py
```

### Linting e Formatação

```bash
# Formatação de código
black src/ tests/

# Ordenação de imports
isort src/ tests/

# Análise estática
flake8 src/ tests/
mypy src/
```

## 📦 Dependências

### Produção

{{#if dependencies.production}}
{{#each dependencies.production}}
- **{{name}}** ({{version}}): {{description}}
{{/each}}
{{else}}
- Definir dependências em `requirements.txt`
{{/if}}

### Desenvolvimento

{{#if dependencies.development}}
{{#each dependencies.development}}
- **{{name}}** ({{version}}): {{description}}
{{/each}}
{{else}}
- pytest: Framework de testes
- black: Formatação de código
- isort: Organização de imports
- flake8: Linting
- mypy: Type checking
{{/if}}

## 🧪 Testes

Este projeto utiliza **pytest** como framework de testes com as seguintes configurações:

- Testes unitários em `tests/unit/`
- Testes de integração em `tests/integration/`
- Cobertura de código com **coverage.py**
- Fixtures compartilhadas em `conftest.py`

### Executando Testes

```bash
# Todos os testes
make test

# Testes com cobertura
make test-coverage

# Testes em modo watch
make test-watch
```

## 📚 Documentação

{{#if has_docs}}
A documentação completa está disponível em `docs/` e pode ser gerada com:

```bash
make docs
```
{{else}}
### Gerando Documentação

```bash
# Instalar sphinx
pip install sphinx sphinx-rtd-theme

# Gerar documentação
sphinx-quickstart docs
make -C docs html
```
{{/if}}

## 🔄 CI/CD

{{#if has_ci}}
Este projeto utiliza **{{ci_platform}}** para integração contínua:

- Testes automatizados em múltiplas versões do Python
- Verificação de qualidade de código
- Deploy automático {{#if deploy_target}}para {{deploy_target}}{{/if}}

Configuração em `.github/workflows/` ou `.gitlab-ci.yml`.
{{else}}
### Configuração de CI/CD

Para configurar CI/CD, utilize os templates em `.github/workflows/` ou configure GitLab CI.
{{/if}}

## 🚀 Deploy

{{#if deployment}}
### {{deployment.platform}}

{{deployment.instructions}}
{{else}}
### Deploy Local

```bash
# Build de produção
make build

# Executar em produção
make run-production
```

### Deploy em Nuvem

Configure as variáveis de ambiente necessárias e utilize os scripts em `scripts/deploy/`.
{{/if}}

## 🔒 Configurações de Segurança

{{#if has_security}}
- Variáveis de ambiente em `.env` (não commitadas)
- Secrets gerenciados via {{security.secrets_manager}}
- Validação de inputs implementada
- {{#if security.features}}{{#each security.features}}
- {{this}}
{{/each}}{{/if}}
{{else}}
- Configure variáveis de ambiente em `.env`
- Não commite secrets ou credenciais
- Utilize ferramentas como `python-dotenv` para carregar configurações
{{/if}}

## 📝 Convenções

### Código

- **PEP 8**: Seguir convenções de estilo Python
- **Type Hints**: Utilizar anotações de tipo
- **Docstrings**: Documentar funções e classes
- **Names**: snake_case para variáveis e funções, PascalCase para classes

### Git

- **Commits**: Seguir padrão Conventional Commits
- **Branches**: `feature/nome-da-feature`, `bugfix/nome-do-bug`
- **PRs**: Template de PR com checklist

### Testes

- **Cobertura**: Mínimo de 80%
- **Naming**: `test_funcionalidade_cenario`
- **Fixtures**: Reutilizar fixtures em `conftest.py`

## 🤝 Contribuição

{{#if contribution_guide}}
Ver [CONTRIBUTING.md](CONTRIBUTING.md) para instruções detalhadas.
{{else}}
1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request
{{/if}}

## 📄 Licença

{{#if license}}
Este projeto está sob a licença {{license}}. Ver arquivo [LICENSE](LICENSE) para mais detalhes.
{{else}}
Distribuído sob a licença MIT. Ver `LICENSE` para mais informações.
{{/if}}

## 📞 Contato

{{#if contact}}
- **Autor**: {{contact.author}}
- **Email**: {{contact.email}}
- **LinkedIn**: {{contact.linkedin}}
{{else}}
- Seu Nome - seu.email@exemplo.com
- Link do Projeto: {{repository_url}}
{{/if}}

## 🙏 Agradecimentos

{{#if acknowledgments}}
{{#each acknowledgments}}
- {{this}}
{{/each}}
{{else}}
- [AI Project Template](https://github.com/yvesmarinho/ai-project-template)
- [Python.org](https://python.org)
- Comunidade Python Brasil
{{/if}}

---

<div align="center">

**[🏠 Voltar ao Topo](#-python-project-template)**

Feito com ❤️ usando [AI Project Template](https://github.com/yvesmarinho/ai-project-template)

</div>