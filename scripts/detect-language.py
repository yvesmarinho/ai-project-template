#!/usr/bin/env python3
"""
AI Project Template - Language Detection System
Detecta automaticamente a linguagem e framework de um projeto baseado em arquivos e estrutura.
Inspirado em: enterprise-project-model patterns
"""

import os
import json
import yaml
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import argparse

@dataclass
class DetectionResult:
    """Resultado da detecção de linguagem e framework"""
    primary_language: str
    confidence: float
    frameworks: List[str]
    package_managers: List[str]
    evidence: Dict[str, List[str]]
    project_type: str
    suggested_structure: Dict[str, str]

class LanguageDetector:
    """Sistema inteligente de detecção de linguagem e framework"""
    
    # Configuração de detecção por arquivo
    FILE_PATTERNS = {
        'python': {
            'files': ['requirements.txt', 'setup.py', 'pyproject.toml', 'poetry.lock', 'Pipfile'],
            'extensions': ['.py', '.pyw'],
            'frameworks': {
                'fastapi': ['fastapi', 'uvicorn'],
                'django': ['django', 'manage.py'],
                'flask': ['flask', 'app.py'],
                'pytest': ['pytest', 'conftest.py'],
                'streamlit': ['streamlit']
            }
        },
        'javascript': {
            'files': ['package.json', 'yarn.lock', 'npm-shrinkwrap.json'],
            'extensions': ['.js', '.mjs', '.cjs'],
            'frameworks': {
                'react': ['react', 'jsx'],
                'vue': ['vue', '.vue'],
                'angular': ['angular', '@angular'],
                'express': ['express'],
                'nextjs': ['next', 'next.config.js'],
                'vite': ['vite', 'vite.config.js']
            }
        },
        'typescript': {
            'files': ['tsconfig.json', 'package.json'],
            'extensions': ['.ts', '.tsx'],
            'frameworks': {
                'react': ['react', '@types/react'],
                'angular': ['@angular/core'],
                'nestjs': ['@nestjs/core'],
                'express': ['express', '@types/express']
            }
        },
        'go': {
            'files': ['go.mod', 'go.sum', 'Gopkg.toml'],
            'extensions': ['.go'],
            'frameworks': {
                'gin': ['gin-gonic/gin'],
                'echo': ['labstack/echo'],
                'fiber': ['gofiber/fiber'],
                'cobra': ['spf13/cobra']
            }
        },
        'rust': {
            'files': ['Cargo.toml', 'Cargo.lock'],
            'extensions': ['.rs'],
            'frameworks': {
                'actix': ['actix-web'],
                'rocket': ['rocket'],
                'warp': ['warp'],
                'tokio': ['tokio']
            }
        },
        'java': {
            'files': ['pom.xml', 'build.gradle', 'gradle.properties'],
            'extensions': ['.java'],
            'frameworks': {
                'spring': ['springframework', 'spring-boot'],
                'quarkus': ['quarkus'],
                'micronaut': ['micronaut']
            }
        },
        'csharp': {
            'files': ['*.csproj', '*.sln', 'packages.config'],
            'extensions': ['.cs'],
            'frameworks': {
                'aspnetcore': ['Microsoft.AspNetCore'],
                'blazor': ['Microsoft.AspNetCore.Components'],
                'maui': ['Microsoft.Maui']
            }
        }
    }
    
    # Padrões de estrutura de projeto
    PROJECT_TYPES = {
        'api': {
            'patterns': ['api/', 'controllers/', 'routes/', 'endpoints/', 'handlers/'],
            'files': ['swagger.json', 'openapi.yaml', 'api.py', 'server.py']
        },
        'webapp': {
            'patterns': ['public/', 'static/', 'assets/', 'components/', 'views/'],
            'files': ['index.html', 'app.html', 'main.html']
        },
        'cli': {
            'patterns': ['cmd/', 'cli/', 'commands/'],
            'files': ['main.py', 'cli.py', 'main.go', 'main.rs']
        },
        'library': {
            'patterns': ['lib/', 'src/lib/', 'library/'],
            'files': ['__init__.py', 'lib.rs', 'index.js']
        }
    }

    def __init__(self, project_path: str):
        """Inicializar detector para um projeto específico"""
        self.project_path = Path(project_path).resolve()
        self.evidence = {}
        
    def detect(self) -> DetectionResult:
        """Executar detecção completa"""
        print(f"🔍 Analisando projeto: {self.project_path}")
        
        # Coletar evidências
        file_evidence = self._detect_by_files()
        extension_evidence = self._detect_by_extensions()
        content_evidence = self._detect_by_content()
        structure_evidence = self._detect_project_type()
        
        # Combinar evidências e calcular scores
        language_scores = self._calculate_language_scores(
            file_evidence, extension_evidence, content_evidence
        )
        
        # Determinar linguagem principal
        primary_language = max(language_scores.items(), key=lambda x: x[1])[0]
        confidence = language_scores[primary_language]
        
        # Detectar frameworks
        frameworks = self._detect_frameworks(primary_language, content_evidence)
        
        # Detectar gerenciadores de pacote
        package_managers = self._detect_package_managers(primary_language)
        
        # Sugerir estrutura
        suggested_structure = self._suggest_structure(primary_language, structure_evidence)
        
        return DetectionResult(
            primary_language=primary_language,
            confidence=confidence,
            frameworks=frameworks,
            package_managers=package_managers,
            evidence=self.evidence,
            project_type=structure_evidence,
            suggested_structure=suggested_structure
        )
    
    def _detect_by_files(self) -> Dict[str, float]:
        """Detectar linguagem baseado em arquivos específicos"""
        scores = {}
        file_evidence = {}
        
        for language, config in self.FILE_PATTERNS.items():
            found_files = []
            score = 0.0
            
            for file_pattern in config['files']:
                matches = list(self.project_path.glob(f"**/{file_pattern}"))
                if matches:
                    found_files.extend([str(m.relative_to(self.project_path)) for m in matches])
                    # Peso maior para arquivos na raiz
                    root_matches = [m for m in matches if m.parent == self.project_path]
                    score += len(root_matches) * 0.8 + len(matches) * 0.5
            
            scores[language] = score
            file_evidence[language] = found_files
        
        self.evidence['files'] = file_evidence
        return scores
    
    def _detect_by_extensions(self) -> Dict[str, float]:
        """Detectar linguagem baseado em extensões de arquivo"""
        scores = {}
        extension_evidence = {}
        
        for language, config in self.FILE_PATTERNS.items():
            file_count = 0
            found_files = []
            
            for ext in config['extensions']:
                matches = list(self.project_path.glob(f"**/*{ext}"))
                # Filtrar arquivos muito grandes ou em diretórios irrelevantes
                filtered_matches = [
                    m for m in matches 
                    if m.stat().st_size < 1024*1024  # < 1MB
                    and not any(part.startswith('.') for part in m.parts)  # Não em pastas ocultas
                    and 'node_modules' not in str(m)
                    and '__pycache__' not in str(m)
                ]
                
                file_count += len(filtered_matches)
                found_files.extend([str(m.relative_to(self.project_path)) for m in filtered_matches[:10]])
            
            scores[language] = file_count * 0.1  # Peso menor que arquivos específicos
            extension_evidence[language] = found_files
        
        self.evidence['extensions'] = extension_evidence
        return scores
    
    def _detect_by_content(self) -> Dict[str, Dict[str, List[str]]]:
        """Detectar frameworks baseado no conteúdo dos arquivos"""
        content_evidence = {}
        
        for language, config in self.FILE_PATTERNS.items():
            content_evidence[language] = {}
            
            # Analisar arquivos de configuração específicos
            for file_pattern in config['files']:
                matches = list(self.project_path.glob(f"**/{file_pattern}"))
                for match in matches[:5]:  # Limitar análise
                    try:
                        content = match.read_text(encoding='utf-8')
                        
                        # Procurar por frameworks específicos
                        for framework, keywords in config['frameworks'].items():
                            found_keywords = []
                            for keyword in keywords:
                                if keyword in content:
                                    found_keywords.append(keyword)
                            
                            if found_keywords:
                                if framework not in content_evidence[language]:
                                    content_evidence[language][framework] = []
                                content_evidence[language][framework].extend(found_keywords)
                    
                    except (UnicodeDecodeError, PermissionError):
                        continue
        
        self.evidence['content'] = content_evidence
        return content_evidence
    
    def _detect_project_type(self) -> str:
        """Detectar tipo de projeto baseado na estrutura"""
        type_scores = {}
        
        for project_type, config in self.PROJECT_TYPES.items():
            score = 0.0
            
            # Verificar padrões de diretório
            for pattern in config['patterns']:
                matches = list(self.project_path.glob(f"**/{pattern}"))
                score += len(matches) * 2.0
            
            # Verificar arquivos específicos
            for file_pattern in config['files']:
                matches = list(self.project_path.glob(f"**/{file_pattern}"))
                score += len(matches) * 1.5
            
            type_scores[project_type] = score
        
        if not type_scores or max(type_scores.values()) == 0:
            return 'api'  # Default
        
        return max(type_scores.items(), key=lambda x: x[1])[0]
    
    def _calculate_language_scores(self, file_evidence: Dict, extension_evidence: Dict, content_evidence: Dict) -> Dict[str, float]:
        """Calcular scores finais combinando todas as evidências"""
        final_scores = {}
        
        for language in self.FILE_PATTERNS.keys():
            score = 0.0
            
            # Peso dos arquivos específicos (mais importante)
            score += file_evidence.get(language, 0) * 3.0
            
            # Peso das extensões
            score += extension_evidence.get(language, 0) * 1.0
            
            # Peso do conteúdo (frameworks encontrados)
            framework_count = len(content_evidence.get(language, {}))
            score += framework_count * 2.0
            
            # Normalizar score
            final_scores[language] = min(score / 10.0, 1.0)
        
        # Se nenhuma linguagem detectada, usar Python como fallback
        if not final_scores or max(final_scores.values()) == 0:
            final_scores['python'] = 0.5
        
        return final_scores
    
    def _detect_frameworks(self, language: str, content_evidence: Dict) -> List[str]:
        """Detectar frameworks específicos da linguagem"""
        if language not in content_evidence:
            return []
        
        return list(content_evidence[language].keys())
    
    def _detect_package_managers(self, language: str) -> List[str]:
        """Detectar gerenciadores de pacote baseado na linguagem e arquivos"""
        managers = []
        
        manager_files = {
            'npm': ['package.json', 'package-lock.json'],
            'yarn': ['yarn.lock'],
            'pip': ['requirements.txt', 'setup.py'],
            'poetry': ['pyproject.toml', 'poetry.lock'],
            'pipenv': ['Pipfile', 'Pipfile.lock'],
            'cargo': ['Cargo.toml', 'Cargo.lock'],
            'go_modules': ['go.mod', 'go.sum'],
            'maven': ['pom.xml'],
            'gradle': ['build.gradle', 'gradle.properties'],
            'nuget': ['*.csproj', '*.sln']
        }
        
        for manager, files in manager_files.items():
            for file_pattern in files:
                if list(self.project_path.glob(f"**/{file_pattern}")):
                    managers.append(manager)
                    break
        
        return managers
    
    def _suggest_structure(self, language: str, project_type: str) -> Dict[str, str]:
        """Sugerir estrutura de pastas baseada na linguagem e tipo"""
        structures = {
            'python': {
                'api': 'src/api/, tests/, docs/, config/',
                'cli': 'src/cli/, tests/, docs/',
                'webapp': 'src/webapp/, static/, templates/, tests/',
                'library': 'src/lib/, tests/, docs/'
            },
            'javascript': {
                'api': 'src/routes/, middleware/, models/, tests/',
                'webapp': 'src/components/, public/, assets/, tests/',
                'cli': 'src/commands/, bin/, tests/',
                'library': 'src/lib/, tests/, docs/'
            },
            'go': {
                'api': 'cmd/, internal/, pkg/, api/',
                'cli': 'cmd/, internal/, pkg/',
                'webapp': 'cmd/, internal/, web/, static/',
                'library': 'pkg/, internal/, examples/'
            }
        }
        
        return structures.get(language, {}).get(project_type, 'src/, tests/, docs/')

def main():
    """CLI para detecção de linguagem"""
    parser = argparse.ArgumentParser(description='AI Project Template - Language Detection')
    parser.add_argument('project_path', help='Caminho para o projeto a ser analisado')
    parser.add_argument('--output', '-o', choices=['json', 'yaml', 'text'], default='text',
                        help='Formato de saída')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Output detalhado com evidências')
    
    args = parser.parse_args()
    
    # Verificar se o caminho existe
    if not os.path.exists(args.project_path):
        print(f"❌ Erro: Caminho '{args.project_path}' não encontrado")
        return 1
    
    # Executar detecção
    detector = LanguageDetector(args.project_path)
    result = detector.detect()
    
    # Output baseado no formato escolhido
    if args.output == 'json':
        print(json.dumps(asdict(result), indent=2, ensure_ascii=False))
    elif args.output == 'yaml':
        print(yaml.dump(asdict(result), default_flow_style=False, allow_unicode=True))
    else:
        # Formato texto amigável
        print(f"\n🎯 **Resultado da Detecção:**")
        print(f"   📋 Projeto: {args.project_path}")
        print(f"   🔤 Linguagem: {result.primary_language}")
        print(f"   📊 Confiança: {result.confidence:.1%}")
        print(f"   🚀 Frameworks: {', '.join(result.frameworks) if result.frameworks else 'Nenhum detectado'}")
        print(f"   📦 Gerenciadores: {', '.join(result.package_managers) if result.package_managers else 'Nenhum detectado'}")
        print(f"   🏗️  Tipo: {result.project_type}")
        print(f"   📁 Estrutura sugerida: {result.suggested_structure}")
        
        if args.verbose and result.evidence:
            print(f"\n📋 **Evidências encontradas:**")
            for category, evidence in result.evidence.items():
                print(f"   {category.upper()}:")
                for lang, items in evidence.items():
                    if items:
                        print(f"     {lang}: {items[:3]}{'...' if len(items) > 3 else ''}")
    
    return 0

if __name__ == '__main__':
    exit(main())