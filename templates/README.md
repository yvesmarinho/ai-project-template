# Templates Metadata - AI Project Template

## 📊 Template Structure Overview

**Last Updated:** 2025-10-20  
**Template Version:** v1.0.0  
**Total Templates:** 25+ files across 4 categories  

## 📁 Template Organization

### **1. Base Structure (`templates/base-structure/`)**
Universal templates copied to all projects:

| Template | Purpose | Variables Used |
|----------|---------|----------------|
| `README.template.md` | Project documentation | PROJECT_NAME, PROJECT_DESCRIPTION, REPOSITORY_URL |
| `.gitignore.template` | Version control exclusions | LANGUAGE_SPECIFIC_IGNORES, FRAMEWORK_SPECIFIC_IGNORES |
| `CHANGELOG.template.md` | Change tracking | PROJECT_NAME, INITIAL_VERSION, CREATION_DATE |
| `CONTRIBUTING.template.md` | Contribution guidelines | PROJECT_NAME, REPOSITORY_URL, CONTACT_INFORMATION |

### **2. Language-Specific (`templates/language-specific/`)**
Templates specific to programming languages:

#### **Python (`python/`)**
- `requirements.template.txt` - Dependencies management
- `pyproject.template.toml` - Modern Python configuration
- `.gitignore` - Python-specific ignores

#### **JavaScript (`javascript/`)**
- `package.template.json` - NPM package configuration
- `.gitignore` - Node.js-specific ignores

#### **Go (`go/`)**
- `go.template.mod` - Go modules configuration
- `.gitignore` - Go-specific ignores

#### **Rust (`rust/`)**
- `Cargo.template.toml` - Rust package configuration
- `.gitignore` - Rust-specific ignores

### **3. Framework-Specific (`templates/framework-specific/`)**
Templates for specific frameworks:

| Framework | Directory | Status |
|-----------|-----------|---------|
| FastAPI | `fastapi/` | 📁 Created |
| React | `react/` | 📁 Created |
| Next.js | `nextjs/` | 📁 Created |
| Spring Boot | `spring-boot/` | 📁 Created |

### **4. Project Type (`templates/project-type/`)**
Templates by project type:

| Type | Directory | Purpose |
|------|-----------|---------|
| API | `api/` | REST/GraphQL APIs |
| CLI | `cli/` | Command-line tools |
| Web App | `webapp/` | Web applications |
| Library | `library/` | Reusable libraries |

## 🔧 Template Variables System

### **Universal Variables:**
- `{{PROJECT_NAME}}` - Project name
- `{{PROJECT_DESCRIPTION}}` - Project description  
- `{{PROJECT_VERSION}}` - Initial version (default: 0.1.0)
- `{{AUTHOR_NAME}}` - Author full name
- `{{AUTHOR_EMAIL}}` - Author email
- `{{LICENSE}}` - License type (default: MIT)
- `{{REPOSITORY_URL}}` - Git repository URL
- `{{CREATION_DATE}}` - Project creation date

### **Language-Specific Variables:**

#### **Python:**
- `{{PYTHON_VERSION}}` - Python version requirement
- `{{PRODUCTION_DEPENDENCIES}}` - Runtime dependencies
- `{{DEVELOPMENT_DEPENDENCIES}}` - Dev dependencies

#### **JavaScript/Node.js:**
- `{{NODE_VERSION}}` - Node.js version requirement
- `{{NPM_VERSION}}` - NPM version requirement
- `{{MAIN_FILE}}` - Entry point file
- `{{START_COMMAND}}` - Start script
- `{{DEV_COMMAND}}` - Development script

#### **Go:**
- `{{MODULE_NAME}}` - Go module name
- `{{GO_VERSION}}` - Go version requirement
- `{{DEPENDENCIES}}` - Go dependencies

#### **Rust:**
- `{{RUST_EDITION}}` - Rust edition (2021, 2018)
- `{{BINARY_NAME}}` - Binary executable name
- `{{LIBRARY_NAME}}` - Library name

## 🚀 Universal Build System

### **Makefile Capabilities:**
- **Auto-detection** of 5+ languages (Python, Node.js, Go, Rust, Java)
- **18 universal commands** that adapt to detected language
- **Color-coded output** for better UX
- **Fallback support** for unknown project types

### **Available Commands:**
```bash
make help          # Show all available commands
make init          # Initialize project with language detection
make install       # Install dependencies
make dev           # Start development server
make build         # Build the project
make test          # Run tests
make lint          # Run linting
make format        # Format code
make clean         # Clean build artifacts
make docker-build  # Build Docker image
make docs          # Generate documentation
make deploy        # Deploy the project
make health        # Check project health
make update        # Update dependencies
make security      # Run security checks
make benchmark     # Run performance benchmarks
```

## 📋 Template Processing Workflow

### **1. Language Detection:**
```bash
# Detection methods:
- File extensions (.py, .js, .go, .rs, .java, etc.)
- Configuration files (package.json, go.mod, Cargo.toml, etc.)
- Directory structure patterns
- Build files (Makefile, pom.xml, build.gradle, etc.)
```

### **2. Template Selection:**
```bash
# Selection logic:
templates/base-structure/        → Always copied
templates/language-specific/X/   → If language X detected
templates/framework-specific/Y/  → If framework Y detected  
templates/project-type/Z/        → If type Z specified
```

### **3. Variable Substitution:**
```bash
# Processing pipeline:
1. Load template files
2. Extract variables from mcp-questions.yaml
3. Replace {{VARIABLE}} placeholders
4. Generate final files in target directory
```

## 🎯 Usage Examples

### **Python Project:**
```bash
# Detected files: requirements.txt, *.py
# Templates used:
- base-structure/* (all)
- language-specific/python/*
- project-type/api/* (if API project)
```

### **Node.js Project:**
```bash
# Detected files: package.json, *.js
# Templates used:
- base-structure/* (all)
- language-specific/javascript/*
- framework-specific/react/* (if React detected)
```

### **Go Project:**
```bash
# Detected files: go.mod, *.go
# Templates used:
- base-structure/* (all)
- language-specific/go/*
- project-type/cli/* (if CLI project)
```

## 📊 Template Statistics

### **Coverage by Language:**
- ✅ **Python**: Complete (config, deps, ignores)
- ✅ **JavaScript**: Complete (package.json, ignores)
- ✅ **Go**: Complete (go.mod, ignores)
- ✅ **Rust**: Complete (Cargo.toml, ignores)
- 🔄 **TypeScript**: Planned (extends JavaScript)
- 🔄 **Java**: Planned (Maven/Gradle)
- 🔄 **C#**: Planned (.csproj, .sln)

### **Framework Support:**
- 📁 **FastAPI**: Directory created
- 📁 **React**: Directory created  
- 📁 **Next.js**: Directory created
- 📁 **Spring Boot**: Directory created
- 🔄 **Django**: Planned
- 🔄 **Express**: Planned
- 🔄 **Gin**: Planned

## 🔄 Next Implementation Steps

### **Phase 1 - Complete Current Templates:**
1. Add framework-specific templates (FastAPI, React, etc.)
2. Implement TypeScript and Java language templates
3. Create project-type specific templates

### **Phase 2 - Advanced Features:**
1. Conditional template logic
2. Template inheritance system
3. Dynamic dependency resolution

### **Phase 3 - Integration:**
1. Connect with language detection system
2. Implement variable substitution engine
3. Create template validation system

---

**Template System Status:** 🟢 Foundation Complete, Ready for Enhancement  
**Next Milestone:** Framework-specific template implementation  
**Completion:** Base structure 100%, Language-specific 60%, Framework-specific 10%