#!/usr/bin/env python3
"""
Framework Detection Engine - AI Project Template
Sistema avançado de detecção de frameworks com análise profunda de código
"""

import os
import re
import json
import yaml
import ast
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass, asdict
import argparse


@dataclass
class FrameworkInfo:
    """Informações detalhadas sobre um framework detectado."""
    name: str
    version: Optional[str]
    confidence: float
    evidence: List[str]
    category: str  # web, cli, desktop, mobile, etc.
    description: str


@dataclass
class FrameworkDetectionResult:
    """Resultado completo da detecção de frameworks."""
    primary_framework: Optional[str]
    detected_frameworks: List[FrameworkInfo]
    language: str
    project_type: str
    recommendations: List[str]
    config_files: List[str]
    dependencies: Dict[str, str]


class FrameworkDetector:
    """Detector avançado de frameworks com análise de código."""
    
    # Definições de frameworks por linguagem
    FRAMEWORK_DEFINITIONS = {
        'python': {
            'fastapi': {
                'patterns': [
                    r'from\s+fastapi\s+import',
                    r'FastAPI\(',
                    r'@app\.(get|post|put|delete|patch)',
                    r'uvicorn\.run'
                ],
                'files': ['main.py', 'app.py', 'api.py'],
                'dependencies': ['fastapi', 'uvicorn'],
                'category': 'web_api',
                'description': 'Modern, fast web framework for building APIs'
            },
            'django': {
                'patterns': [
                    r'from\s+django',
                    r'Django',
                    r'manage\.py',
                    r'INSTALLED_APPS',
                    r'settings\.py'
                ],
                'files': ['manage.py', 'settings.py', 'wsgi.py', 'asgi.py'],
                'dependencies': ['django', 'djangorestframework'],
                'category': 'web_framework',
                'description': 'High-level Python web framework'
            },
            'flask': {
                'patterns': [
                    r'from\s+flask\s+import',
                    r'Flask\(',
                    r'@app\.route',
                    r'app\.run\('
                ],
                'files': ['app.py', 'main.py', 'server.py'],
                'dependencies': ['flask', 'flask-restful'],
                'category': 'web_framework',
                'description': 'Lightweight WSGI web application framework'
            },
            'streamlit': {
                'patterns': [
                    r'import\s+streamlit',
                    r'st\.',
                    r'streamlit\.run'
                ],
                'files': ['app.py', 'main.py', 'streamlit_app.py'],
                'dependencies': ['streamlit'],
                'category': 'web_app',
                'description': 'Framework for data science web apps'
            },
            'pytorch': {
                'patterns': [
                    r'import\s+torch',
                    r'torch\.',
                    r'nn\.Module',
                    r'torch\.nn'
                ],
                'files': ['model.py', 'train.py', 'main.py'],
                'dependencies': ['torch', 'torchvision'],
                'category': 'machine_learning',
                'description': 'Deep learning framework'
            },
            'tensorflow': {
                'patterns': [
                    r'import\s+tensorflow',
                    r'tf\.',
                    r'keras',
                    r'tf\.keras'
                ],
                'files': ['model.py', 'train.py', 'main.py'],
                'dependencies': ['tensorflow', 'keras'],
                'category': 'machine_learning',
                'description': 'Machine learning platform'
            },
            'pytest': {
                'patterns': [
                    r'import\s+pytest',
                    r'def\s+test_',
                    r'@pytest\.',
                    r'pytest\.main'
                ],
                'files': ['test_*.py', 'tests/', 'pytest.ini', 'conftest.py'],
                'dependencies': ['pytest'],
                'category': 'testing',
                'description': 'Testing framework'
            }
        },
        'javascript': {
            'react': {
                'patterns': [
                    r'import.*React',
                    r'from\s+["\']react["\']',
                    r'jsx',
                    r'useState',
                    r'useEffect'
                ],
                'files': ['App.js', 'App.jsx', 'index.js'],
                'dependencies': ['react', 'react-dom'],
                'category': 'frontend_framework',
                'description': 'Library for building user interfaces'
            },
            'nextjs': {
                'patterns': [
                    r'import.*next',
                    r'from\s+["\']next',
                    r'getStaticProps',
                    r'getServerSideProps'
                ],
                'files': ['next.config.js', 'pages/', '_app.js'],
                'dependencies': ['next'],
                'category': 'fullstack_framework',
                'description': 'React framework for production'
            },
            'express': {
                'patterns': [
                    r'require\(["\']express["\']\)',
                    r'express\(\)',
                    r'app\.get',
                    r'app\.listen'
                ],
                'files': ['app.js', 'server.js', 'index.js'],
                'dependencies': ['express'],
                'category': 'web_api',
                'description': 'Fast, minimalist web framework'
            },
            'vue': {
                'patterns': [
                    r'import.*Vue',
                    r'from\s+["\']vue["\']',
                    r'createApp',
                    r'\.vue$'
                ],
                'files': ['main.js', 'App.vue', 'vue.config.js'],
                'dependencies': ['vue'],
                'category': 'frontend_framework',
                'description': 'Progressive JavaScript framework'
            },
            'angular': {
                'patterns': [
                    r'@angular/',
                    r'@Component',
                    r'@Injectable',
                    r'angular\.json'
                ],
                'files': ['angular.json', 'app.module.ts', 'main.ts'],
                'dependencies': ['@angular/core'],
                'category': 'frontend_framework',
                'description': 'Platform for building mobile and desktop web applications'
            },
            'svelte': {
                'patterns': [
                    r'\.svelte$',
                    r'svelte/',
                    r'onMount',
                    r'createEventDispatcher'
                ],
                'files': ['App.svelte', 'main.js', 'svelte.config.js'],
                'dependencies': ['svelte'],
                'category': 'frontend_framework',
                'description': 'Cybernetically enhanced web apps'
            }
        },
        'typescript': {
            'nestjs': {
                'patterns': [
                    r'@nestjs/',
                    r'@Controller',
                    r'@Injectable',
                    r'@Module'
                ],
                'files': ['main.ts', 'app.module.ts', 'nest-cli.json'],
                'dependencies': ['@nestjs/core'],
                'category': 'web_api',
                'description': 'Progressive Node.js framework'
            }
        }
    }
    
    def __init__(self, project_path: str):
        """Inicializar detector."""
        self.project_path = Path(project_path).resolve()
        self.language = None
        
    def detect(self, language: str = None) -> FrameworkDetectionResult:
        """Executar detecção completa de frameworks."""
        print(f"🔍 Detectando frameworks em: {self.project_path}")
        
        # Auto-detectar linguagem se não fornecida
        if not language:
            language = self._auto_detect_language()
        
        self.language = language
        
        # Detectar frameworks
        frameworks = self._detect_frameworks()
        
        # Determinar framework principal
        primary_framework = None
        if frameworks:
            primary_framework = max(frameworks, key=lambda f: f.confidence).name
        
        # Detectar tipo de projeto
        project_type = self._detect_project_type(frameworks)
        
        # Gerar recomendações
        recommendations = self._generate_recommendations(frameworks, project_type)
        
        # Encontrar arquivos de configuração
        config_files = self._find_config_files()
        
        # Extrair dependências
        dependencies = self._extract_dependencies()
        
        return FrameworkDetectionResult(
            primary_framework=primary_framework,
            detected_frameworks=frameworks,
            language=language,
            project_type=project_type,
            recommendations=recommendations,
            config_files=config_files,
            dependencies=dependencies
        )
    
    def _auto_detect_language(self) -> str:
        """Auto-detectar linguagem principal do projeto."""
        language_files = {
            'python': ['*.py', 'requirements.txt', 'setup.py', 'pyproject.toml'],
            'javascript': ['*.js', '*.jsx', 'package.json'],
            'typescript': ['*.ts', '*.tsx', 'tsconfig.json'],
            'go': ['*.go', 'go.mod'],
            'rust': ['*.rs', 'Cargo.toml'],
            'java': ['*.java', 'pom.xml', 'build.gradle']
        }
        
        scores = {}
        for lang, patterns in language_files.items():
            count = 0
            for pattern in patterns:
                count += len(list(self.project_path.glob(f"**/{pattern}")))
            scores[lang] = count
        
        return max(scores.items(), key=lambda x: x[1])[0] if scores else 'python'
    
    def _detect_frameworks(self) -> List[FrameworkInfo]:
        """Detectar frameworks baseado em padrões de código."""
        if self.language not in self.FRAMEWORK_DEFINITIONS:
            return []
        
        frameworks = []
        definitions = self.FRAMEWORK_DEFINITIONS[self.language]
        
        for framework_name, config in definitions.items():
            evidence = []
            confidence = 0.0
            version = None
            
            # Verificar padrões em arquivos
            for pattern in config['patterns']:
                matches = self._search_pattern_in_files(pattern)
                if matches:
                    evidence.extend(matches[:3])  # Limitar evidências
                    confidence += len(matches) * 0.2
            
            # Verificar arquivos específicos
            for file_pattern in config['files']:
                files = list(self.project_path.glob(f"**/{file_pattern}"))
                if files:
                    evidence.extend([str(f.relative_to(self.project_path)) for f in files[:2]])
                    confidence += len(files) * 0.3
            
            # Verificar dependências
            deps = self._check_dependencies(config['dependencies'])
            if deps:
                evidence.extend([f"dependency: {dep}" for dep in deps[:2]])
                confidence += len(deps) * 0.4
                
                # Tentar extrair versão
                version = self._extract_version(framework_name, deps)
            
            # Se há evidência suficiente, adicionar framework
            if confidence > 0.5:
                frameworks.append(FrameworkInfo(
                    name=framework_name,
                    version=version,
                    confidence=min(confidence, 1.0),
                    evidence=evidence,
                    category=config['category'],
                    description=config['description']
                ))
        
        # Ordenar por confiança
        return sorted(frameworks, key=lambda f: f.confidence, reverse=True)
    
    def _search_pattern_in_files(self, pattern: str) -> List[str]:
        """Buscar padrão em arquivos do projeto."""
        matches = []
        regex = re.compile(pattern, re.IGNORECASE | re.MULTILINE)
        
        # Definir extensões por linguagem
        extensions = {
            'python': ['.py'],
            'javascript': ['.js', '.jsx', '.mjs'],
            'typescript': ['.ts', '.tsx'],
            'go': ['.go'],
            'rust': ['.rs'],
            'java': ['.java']
        }.get(self.language, ['.py'])
        
        for ext in extensions:
            for file_path in self.project_path.glob(f"**/*{ext}"):
                if self._should_skip_file(file_path):
                    continue
                
                try:
                    content = file_path.read_text(encoding='utf-8')
                    if regex.search(content):
                        matches.append(str(file_path.relative_to(self.project_path)))
                        if len(matches) >= 10:  # Limitar resultados
                            break
                except (UnicodeDecodeError, PermissionError):
                    continue
        
        return matches
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Verificar se deve pular arquivo na análise."""
        skip_patterns = [
            '__pycache__', 'node_modules', '.git', '.venv', 'venv',
            'build', 'dist', 'target', '.pytest_cache', 'coverage'
        ]
        
        path_str = str(file_path)
        return any(pattern in path_str for pattern in skip_patterns) or file_path.stat().st_size > 1024*1024
    
    def _check_dependencies(self, dependencies: List[str]) -> List[str]:
        """Verificar se dependências estão presentes."""
        found_deps = []
        
        # Arquivos de dependência por linguagem
        dep_files = {
            'python': ['requirements.txt', 'setup.py', 'pyproject.toml', 'Pipfile'],
            'javascript': ['package.json'],
            'typescript': ['package.json'],
            'go': ['go.mod'],
            'rust': ['Cargo.toml'],
            'java': ['pom.xml', 'build.gradle']
        }.get(self.language, [])
        
        for dep_file in dep_files:
            file_path = self.project_path / dep_file
            if file_path.exists():
                try:
                    content = file_path.read_text()
                    for dep in dependencies:
                        if dep in content:
                            found_deps.append(dep)
                except (UnicodeDecodeError, PermissionError):
                    continue
        
        return found_deps
    
    def _extract_version(self, framework: str, dependencies: List[str]) -> Optional[str]:
        """Extrair versão do framework."""
        # Implementação básica - pode ser expandida
        if self.language == 'python':
            req_file = self.project_path / 'requirements.txt'
            if req_file.exists():
                content = req_file.read_text()
                for dep in dependencies:
                    match = re.search(f'{dep}[>=<~!]*([0-9.]+)', content)
                    if match:
                        return match.group(1)
        
        elif self.language in ['javascript', 'typescript']:
            package_file = self.project_path / 'package.json'
            if package_file.exists():
                try:
                    with open(package_file) as f:
                        package_data = json.load(f)
                    
                    for section in ['dependencies', 'devDependencies']:
                        if section in package_data:
                            for dep in dependencies:
                                if dep in package_data[section]:
                                    version = package_data[section][dep]
                                    # Limpar prefixos como ^, ~, >=
                                    clean_version = re.sub(r'[^0-9.]', '', version)
                                    return clean_version
                except (json.JSONDecodeError, KeyError):
                    pass
        
        return None
    
    def _detect_project_type(self, frameworks: List[FrameworkInfo]) -> str:
        """Detectar tipo de projeto baseado nos frameworks."""
        if not frameworks:
            return 'library'
        
        # Mapear categorias para tipos de projeto
        category_mapping = {
            'web_api': 'api',
            'web_framework': 'webapp',
            'frontend_framework': 'webapp',
            'fullstack_framework': 'webapp',
            'machine_learning': 'ml_project',
            'testing': 'library',
            'cli': 'cli'
        }
        
        primary_category = frameworks[0].category
        return category_mapping.get(primary_category, 'library')
    
    def _generate_recommendations(self, frameworks: List[FrameworkInfo], project_type: str) -> List[str]:
        """Gerar recomendações baseadas nos frameworks detectados."""
        recommendations = []
        
        if not frameworks:
            recommendations.append("Consider adding a framework to structure your project")
            return recommendations
        
        primary_framework = frameworks[0]
        
        # Recomendações específicas por framework
        framework_recommendations = {
            'fastapi': [
                "Add uvicorn for ASGI server",
                "Consider pydantic for data validation",
                "Add pytest for testing",
                "Use SQLAlchemy for database ORM"
            ],
            'django': [
                "Add djangorestframework for API development",
                "Consider celery for background tasks",
                "Add django-cors-headers for CORS support",
                "Use pytest-django for testing"
            ],
            'react': [
                "Add React Router for navigation",
                "Consider Redux or Zustand for state management",
                "Add testing-library for component testing",
                "Use TypeScript for better type safety"
            ],
            'express': [
                "Add helmet for security headers",
                "Consider joi or yup for validation",
                "Add jest and supertest for testing",
                "Use TypeScript for better development experience"
            ]
        }
        
        if primary_framework.name in framework_recommendations:
            recommendations.extend(framework_recommendations[primary_framework.name])
        
        # Recomendações gerais por tipo de projeto
        type_recommendations = {
            'api': ["Add API documentation (OpenAPI/Swagger)", "Implement proper error handling", "Add rate limiting"],
            'webapp': ["Implement responsive design", "Add SEO optimization", "Consider PWA features"],
            'ml_project': ["Add data validation", "Implement model versioning", "Add experiment tracking"],
            'cli': ["Add proper argument parsing", "Implement help system", "Add configuration file support"]
        }
        
        if project_type in type_recommendations:
            recommendations.extend(type_recommendations[project_type])
        
        return recommendations[:5]  # Limitar recomendações
    
    def _find_config_files(self) -> List[str]:
        """Encontrar arquivos de configuração do projeto."""
        config_patterns = [
            '*.json', '*.yaml', '*.yml', '*.toml', '*.ini', '*.cfg',
            '.env*', 'Dockerfile', 'docker-compose.yml', 'Makefile'
        ]
        
        config_files = []
        for pattern in config_patterns:
            files = list(self.project_path.glob(pattern))
            config_files.extend([str(f.relative_to(self.project_path)) for f in files])
        
        return sorted(config_files)
    
    def _extract_dependencies(self) -> Dict[str, str]:
        """Extrair lista de dependências do projeto."""
        dependencies = {}
        
        if self.language == 'python':
            req_file = self.project_path / 'requirements.txt'
            if req_file.exists():
                content = req_file.read_text()
                for line in content.split('\n'):
                    line = line.strip()
                    if line and not line.startswith('#'):
                        match = re.match(r'([a-zA-Z0-9_-]+)([>=<~!]*[0-9.]*)', line)
                        if match:
                            name, version = match.groups()
                            dependencies[name] = version or 'latest'
        
        elif self.language in ['javascript', 'typescript']:
            package_file = self.project_path / 'package.json'
            if package_file.exists():
                try:
                    with open(package_file) as f:
                        package_data = json.load(f)
                    
                    for section in ['dependencies', 'devDependencies']:
                        if section in package_data:
                            dependencies.update(package_data[section])
                except json.JSONDecodeError:
                    pass
        
        return dependencies


def main():
    """CLI principal."""
    parser = argparse.ArgumentParser(description='Framework Detection Engine')
    parser.add_argument('project_path', help='Caminho para o projeto')
    parser.add_argument('--language', '-l', help='Linguagem específica para análise')
    parser.add_argument('--output', '-o', choices=['json', 'yaml', 'text'], default='text',
                        help='Formato de saída')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Output detalhado')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.project_path):
        print(f"❌ Erro: Caminho '{args.project_path}' não encontrado")
        return 1
    
    # Executar detecção
    detector = FrameworkDetector(args.project_path)
    result = detector.detect(args.language)
    
    # Output
    if args.output == 'json':
        print(json.dumps(asdict(result), indent=2, ensure_ascii=False))
    elif args.output == 'yaml':
        print(yaml.dump(asdict(result), default_flow_style=False, allow_unicode=True))
    else:
        print(f"\n🚀 **Detecção de Frameworks:**")
        print(f"   📁 Projeto: {args.project_path}")
        print(f"   🔤 Linguagem: {result.language}")
        print(f"   🏗️  Tipo: {result.project_type}")
        print(f"   🎯 Framework Principal: {result.primary_framework or 'Nenhum detectado'}")
        
        if result.detected_frameworks:
            print(f"\n🔍 **Frameworks Detectados:**")
            for fw in result.detected_frameworks:
                version_info = f" v{fw.version}" if fw.version else ""
                print(f"   • {fw.name}{version_info} ({fw.confidence:.1%}) - {fw.category}")
                if args.verbose:
                    print(f"     {fw.description}")
                    print(f"     Evidências: {', '.join(fw.evidence[:3])}")
        
        if result.recommendations:
            print(f"\n💡 **Recomendações:**")
            for rec in result.recommendations:
                print(f"   • {rec}")
        
        if args.verbose and result.dependencies:
            print(f"\n📦 **Dependências ({len(result.dependencies)}):**")
            for name, version in list(result.dependencies.items())[:10]:
                print(f"   • {name}: {version}")
    
    return 0


if __name__ == '__main__':
    exit(main())