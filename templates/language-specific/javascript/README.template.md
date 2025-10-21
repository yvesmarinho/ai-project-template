# {{project_name}}

{{description}}

## 📦 JavaScript/Node.js Project Template

Este projeto foi criado usando o **AI Project Template** com configurações otimizadas para JavaScript/Node.js.

## 📋 Informações do Projeto

- **Linguagem**: JavaScript (Node.js {{node_version}})
- **Framework**: {{framework}}
- **Tipo**: {{project_type}}
- **Criado em**: {{creation_date}}

## 🚀 Quick Start

### Pré-requisitos

- Node.js {{node_version}} ou superior
- npm {{npm_version}} ou superior (ou yarn/pnpm)

### Instalação

```bash
# Clonar o repositório
git clone {{repository_url}}
cd {{project_name}}

# Instalar dependências
npm install
```

### Execução

```bash
# Desenvolvimento
npm run dev

# Produção
npm start

# Testes
npm test
```

## 📁 Estrutura do Projeto

```
{{project_name}}/
├── src/                   # Código fonte principal
{{#if framework}}
{{#if (eq framework "express")}}
│   ├── app.js            # Aplicação Express
│   ├── routes/           # Rotas da API
│   ├── middleware/       # Middlewares customizados
│   ├── models/           # Modelos de dados
│   ├── controllers/      # Controladores
│   └── utils/            # Utilitários
{{/if}}
{{#if (eq framework "react")}}
│   ├── index.js          # Ponto de entrada React
│   ├── App.js            # Componente principal
│   ├── components/       # Componentes React
│   ├── hooks/            # Custom hooks
│   ├── services/         # Serviços de API
│   └── styles/           # Estilos CSS
├── public/               # Arquivos públicos
│   ├── index.html
│   └── favicon.ico
{{/if}}
{{#if (eq framework "next")}}
│   ├── pages/            # Páginas Next.js
│   ├── components/       # Componentes React
│   ├── styles/           # Estilos CSS
│   └── utils/            # Utilitários
├── public/               # Arquivos estáticos
{{/if}}
{{else}}
│   ├── index.js          # Ponto de entrada
│   ├── modules/          # Módulos da aplicação
│   └── utils/            # Utilitários
{{/if}}
├── tests/                # Testes automatizados
│   ├── unit/
│   └── integration/
├── docs/                 # Documentação
├── package.json          # Configuração do projeto
{{#if (eq framework "next")}}
├── next.config.js        # Configuração Next.js
{{/if}}
└── README.md
```

## 🔧 Desenvolvimento

### Scripts Disponíveis

{{#if framework}}
{{#if (eq framework "express")}}
- `npm start`: Inicia o servidor em produção
- `npm run dev`: Inicia o servidor em modo desenvolvimento (nodemon)
- `npm test`: Executa os testes
- `npm run lint`: Executa o linter (ESLint)
{{/if}}
{{#if (eq framework "react")}}
- `npm start`: Inicia o servidor de desenvolvimento
- `npm run build`: Cria build de produção
- `npm test`: Executa os testes
- `npm run eject`: Ejeta as configurações do Create React App
{{/if}}
{{#if (eq framework "next")}}
- `npm run dev`: Inicia o servidor de desenvolvimento
- `npm run build`: Cria build de produção
- `npm start`: Inicia o servidor de produção
- `npm run lint`: Executa o linter Next.js
{{/if}}
{{else}}
- `npm start`: Executa a aplicação
- `npm run dev`: Executa em modo desenvolvimento
- `npm test`: Executa os testes
- `npm run lint`: Executa o linter
{{/if}}

### Ambiente de Desenvolvimento

{{#if framework}}
{{#if (eq framework "express")}}
Configure as variáveis de ambiente em `.env`:

```bash
PORT=3000
NODE_ENV=development
# Adicione outras variáveis conforme necessário
```
{{/if}}
{{#if (eq framework "react")}}
Variáveis de ambiente devem começar com `REACT_APP_`:

```bash
REACT_APP_API_URL=http://localhost:3001
REACT_APP_ENVIRONMENT=development
```
{{/if}}
{{#if (eq framework "next")}}
Configure as variáveis em `.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
DATABASE_URL=your_database_url
```
{{/if}}
{{else}}
Configure as variáveis de ambiente em `.env`:

```bash
NODE_ENV=development
# Adicione suas variáveis aqui
```
{{/if}}

### Testes

Este projeto utiliza **Jest** como framework de testes:

```bash
# Executar todos os testes
npm test

# Executar testes em modo watch
npm run test:watch

# Executar testes com cobertura
npm run test:coverage

{{#if framework}}
{{#if (eq framework "express")}}
# Testes de integração com supertest
npm run test:integration
{{/if}}
{{/if}}
```

### Linting e Formatação

```bash
# Verificar código com ESLint
npm run lint

# Corrigir automaticamente problemas
npm run lint:fix

{{#if has_prettier}}
# Formatar código com Prettier
npm run format
{{/if}}
```

## 📦 Dependências

### Produção

{{#if framework}}
{{#if (eq framework "express")}}
- **express**: Framework web minimalista
- **cors**: Middleware CORS
- **helmet**: Middleware de segurança
- **morgan**: Logger HTTP
- **dotenv**: Carregador de variáveis de ambiente
{{/if}}
{{#if (eq framework "react")}}
- **react**: Biblioteca para interfaces de usuário
- **react-dom**: DOM renderer para React
- **react-scripts**: Scripts e configurações Create React App
{{/if}}
{{#if (eq framework "next")}}
- **next**: Framework React full-stack
- **react**: Biblioteca para interfaces de usuário
- **react-dom**: DOM renderer para React
{{/if}}
{{else}}
- **dotenv**: Carregador de variáveis de ambiente
{{/if}}

### Desenvolvimento

{{#if framework}}
{{#if (eq framework "express")}}
- **nodemon**: Reinicialização automática do servidor
- **jest**: Framework de testes
- **supertest**: Testes HTTP
- **eslint**: Linter JavaScript
{{/if}}
{{#if (eq framework "react")}}
- **@testing-library/react**: Utilitários de teste React
- **@testing-library/jest-dom**: Matchers Jest customizados
{{/if}}
{{#if (eq framework "next")}}
- **eslint-config-next**: Configuração ESLint para Next.js
{{/if}}
{{else}}
- **nodemon**: Reinicialização automática
- **jest**: Framework de testes
- **eslint**: Linter JavaScript
{{/if}}

## 🚀 Deploy

{{#if framework}}
{{#if (eq framework "express")}}
### Deploy em Produção

```bash
# Build (se necessário)
npm run build

# Iniciar em produção
NODE_ENV=production npm start
```

### Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```
{{/if}}
{{#if (eq framework "react")}}
### Build de Produção

```bash
# Criar build otimizado
npm run build

# Servir build estático
npx serve -s build
```
{{/if}}
{{#if (eq framework "next")}}
### Deploy Next.js

```bash
# Build de produção
npm run build

# Iniciar servidor de produção
npm start
```

Compatível com Vercel, Netlify, e outras plataformas.
{{/if}}
{{else}}
### Deploy

```bash
# Instalar dependências de produção
npm ci --only=production

# Executar aplicação
NODE_ENV=production npm start
```
{{/if}}

## 🔒 Configurações de Segurança

{{#if framework}}
{{#if (eq framework "express")}}
- **Helmet**: Headers de segurança configurados
- **CORS**: Política de CORS restritiva
- **Variáveis de ambiente**: Secrets não commitadas
- **Input validation**: Validação de dados de entrada
{{/if}}
{{/if}}

- Configure variáveis sensíveis em `.env`
- Não commite arquivos `.env` no repositório
- Use HTTPS em produção
- Implemente rate limiting se necessário

## 📝 Convenções

### Código

{{#if framework}}
{{#if (eq framework "react")}}
- **Componentes**: PascalCase (`MyComponent.js`)
- **Hooks**: camelCase começando com `use` (`useCustomHook.js`)
- **Utilitários**: camelCase (`apiService.js`)
{{/if}}
{{else}}
- **Arquivos**: camelCase (`myModule.js`)
- **Classes**: PascalCase
- **Funções**: camelCase
- **Constantes**: UPPER_SNAKE_CASE
{{/if}}

### Git

- **Commits**: Seguir padrão Conventional Commits
- **Branches**: `feature/nome-da-feature`, `bugfix/nome-do-bug`
- **PRs**: Incluir testes e documentação

## 🤝 Contribuição

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Distribuído sob a licença {{license}}. Ver `LICENSE` para mais informações.

## 📞 Contato

- **Autor**: {{author_name}}
- **Email**: {{author_email}}
- **Projeto**: {{repository_url}}

---

<div align="center">

**[🏠 Voltar ao Topo](#-javascriptnodejs-project-template)**

Feito com ❤️ usando [AI Project Template](https://github.com/yvesmarinho/ai-project-template)

</div>