#!/usr/bin/env python3
"""
Sistema de Versionamento Automático - AI Project Template
Implementa padrão filename-vnnn.* para versionamento automático de arquivos
Inspirado em enterprise-project-model patterns
"""

import os
import shutil
import re
import json
import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass, asdict
import argparse


@dataclass
class VersionInfo:
    """Informações de versão de um arquivo."""
    original_file: str
    current_version: int
    versions: List[str]
    last_modified: str
    backup_dir: str


class VersionManager:
    """Gerenciador de versionamento automático."""
    
    def __init__(self, base_dir: str = ".", backup_dir: str = ".versions"):
        """Inicializar o gerenciador de versões.
        
        Args:
            base_dir: Diretório base para versionamento
            backup_dir: Diretório para armazenar backups
        """
        self.base_dir = Path(base_dir)
        self.backup_dir = Path(backup_dir)
        self.version_db_file = self.backup_dir / "version-index.json"
        
        # Criar diretório de backup se não existir
        self.backup_dir.mkdir(exist_ok=True)
        
        # Carregar ou inicializar database de versões
        self.version_db = self._load_version_db()
    
    def _load_version_db(self) -> Dict[str, VersionInfo]:
        """Carregar database de versões."""
        if self.version_db_file.exists():
            try:
                with open(self.version_db_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    return {
                        k: VersionInfo(**v) for k, v in data.items()
                    }
            except Exception as e:
                print(f"⚠️  Erro ao carregar version database: {e}")
        
        return {}
    
    def _save_version_db(self):
        """Salvar database de versões."""
        try:
            data = {k: asdict(v) for k, v in self.version_db.items()}
            with open(self.version_db_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"❌ Erro ao salvar version database: {e}")
    
    def _get_version_pattern(self, filename: str) -> str:
        """Gerar padrão de versão para um arquivo.
        
        Args:
            filename: Nome do arquivo original
            
        Returns:
            Padrão regex para versões do arquivo
        """
        name, ext = os.path.splitext(filename)
        # Escapar caracteres especiais do regex
        escaped_name = re.escape(name)
        escaped_ext = re.escape(ext)
        return f"{escaped_name}-v(\\d+){escaped_ext}"
    
    def _find_existing_versions(self, filename: str) -> List[Tuple[int, str]]:
        """Encontrar versões existentes de um arquivo.
        
        Args:
            filename: Nome do arquivo original
            
        Returns:
            Lista de tuplas (versão, caminho_arquivo)
        """
        pattern = self._get_version_pattern(filename)
        versions = []
        
        # Buscar no diretório de backup
        for file_path in self.backup_dir.glob("*"):
            if file_path.is_file():
                match = re.match(pattern, file_path.name)
                if match:
                    version_num = int(match.group(1))
                    versions.append((version_num, str(file_path)))
        
        return sorted(versions, key=lambda x: x[0])
    
    def _get_next_version(self, filename: str) -> int:
        """Obter próximo número de versão para um arquivo.
        
        Args:
            filename: Nome do arquivo original
            
        Returns:
            Próximo número de versão
        """
        existing_versions = self._find_existing_versions(filename)
        if not existing_versions:
            return 1
        
        highest_version = max(existing_versions, key=lambda x: x[0])[0]
        return highest_version + 1
    
    def create_backup(self, file_path: str) -> Optional[str]:
        """Criar backup versionado de um arquivo.
        
        Args:
            file_path: Caminho do arquivo para backup
            
        Returns:
            Caminho do arquivo de backup criado ou None se erro
        """
        source_path = Path(file_path)
        
        if not source_path.exists():
            print(f"❌ Arquivo não encontrado: {file_path}")
            return None
        
        filename = source_path.name
        next_version = self._get_next_version(filename)
        
        # Gerar nome do backup
        name, ext = os.path.splitext(filename)
        backup_name = f"{name}-v{next_version:03d}{ext}"
        backup_path = self.backup_dir / backup_name
        
        try:
            # Criar backup
            shutil.copy2(source_path, backup_path)
            
            # Atualizar database
            relative_path = str(source_path.relative_to(self.base_dir))
            
            if relative_path in self.version_db:
                version_info = self.version_db[relative_path]
                version_info.current_version = next_version
                version_info.versions.append(str(backup_path))
                version_info.last_modified = datetime.datetime.now().isoformat()
            else:
                version_info = VersionInfo(
                    original_file=relative_path,
                    current_version=next_version,
                    versions=[str(backup_path)],
                    last_modified=datetime.datetime.now().isoformat(),
                    backup_dir=str(self.backup_dir)
                )
                self.version_db[relative_path] = version_info
            
            self._save_version_db()
            
            print(f"✅ Backup criado: {backup_name}")
            return str(backup_path)
            
        except Exception as e:
            print(f"❌ Erro ao criar backup: {e}")
            return None
    
    def restore_version(self, file_path: str, version: int) -> bool:
        """Restaurar uma versão específica de um arquivo.
        
        Args:
            file_path: Caminho do arquivo original
            version: Número da versão para restaurar
            
        Returns:
            True se sucesso, False caso contrário
        """
        source_path = Path(file_path)
        relative_path = str(source_path.relative_to(self.base_dir))
        
        if relative_path not in self.version_db:
            print(f"❌ Arquivo não encontrado no version database: {file_path}")
            return False
        
        version_info = self.version_db[relative_path]
        
        # Encontrar backup da versão solicitada
        filename = source_path.name
        name, ext = os.path.splitext(filename)
        backup_name = f"{name}-v{version:03d}{ext}"
        backup_path = self.backup_dir / backup_name
        
        if not backup_path.exists():
            print(f"❌ Versão {version} não encontrada: {backup_name}")
            return False
        
        try:
            # Criar backup do arquivo atual antes de restaurar
            if source_path.exists():
                self.create_backup(str(source_path))
            
            # Restaurar versão
            shutil.copy2(backup_path, source_path)
            
            print(f"✅ Versão {version} restaurada: {file_path}")
            return True
            
        except Exception as e:
            print(f"❌ Erro ao restaurar versão: {e}")
            return False
    
    def list_versions(self, file_path: Optional[str] = None) -> Dict[str, VersionInfo]:
        """Listar versões disponíveis.
        
        Args:
            file_path: Caminho específico (opcional, se None lista todos)
            
        Returns:
            Dicionário com informações de versão
        """
        if file_path:
            source_path = Path(file_path)
            relative_path = str(source_path.relative_to(self.base_dir))
            
            if relative_path in self.version_db:
                return {relative_path: self.version_db[relative_path]}
            else:
                return {}
        
        return self.version_db.copy()
    
    def cleanup_old_versions(self, file_path: str, keep_versions: int = 5) -> int:
        """Limpar versões antigas, mantendo apenas as mais recentes.
        
        Args:
            file_path: Caminho do arquivo
            keep_versions: Número de versões para manter
            
        Returns:
            Número de versões removidas
        """
        source_path = Path(file_path)
        relative_path = str(source_path.relative_to(self.base_dir))
        
        if relative_path not in self.version_db:
            return 0
        
        version_info = self.version_db[relative_path]
        versions = version_info.versions.copy()
        
        if len(versions) <= keep_versions:
            return 0
        
        # Ordenar versões (mais antigas primeiro)
        versions.sort(key=lambda x: int(re.search(r'-v(\d+)', Path(x).name).group(1)))
        
        # Remover versões antigas
        removed_count = 0
        versions_to_remove = versions[:-keep_versions]
        
        for version_path in versions_to_remove:
            try:
                Path(version_path).unlink()
                version_info.versions.remove(version_path)
                removed_count += 1
            except Exception as e:
                print(f"⚠️  Erro ao remover versão {version_path}: {e}")
        
        if removed_count > 0:
            self._save_version_db()
            print(f"🧹 Removidas {removed_count} versões antigas de {file_path}")
        
        return removed_count
    
    def get_file_history(self, file_path: str) -> List[Dict]:
        """Obter histórico completo de um arquivo.
        
        Args:
            file_path: Caminho do arquivo
            
        Returns:
            Lista com histórico de versões
        """
        source_path = Path(file_path)
        relative_path = str(source_path.relative_to(self.base_dir))
        
        if relative_path not in self.version_db:
            return []
        
        version_info = self.version_db[relative_path]
        history = []
        
        for version_path in version_info.versions:
            try:
                backup_path = Path(version_path)
                if backup_path.exists():
                    stat = backup_path.stat()
                    
                    # Extrair número da versão do nome
                    match = re.search(r'-v(\d+)', backup_path.name)
                    version_num = int(match.group(1)) if match else 0
                    
                    history.append({
                        'version': version_num,
                        'path': str(backup_path),
                        'size': stat.st_size,
                        'modified': datetime.datetime.fromtimestamp(stat.st_mtime).isoformat(),
                        'exists': True
                    })
            except Exception as e:
                print(f"⚠️  Erro ao processar versão {version_path}: {e}")
        
        # Ordenar por versão (mais recente primeiro)
        history.sort(key=lambda x: x['version'], reverse=True)
        return history


def main():
    """Função principal do script."""
    parser = argparse.ArgumentParser(
        description="Sistema de Versionamento Automático - AI Project Template"
    )
    
    parser.add_argument('command', choices=['backup', 'restore', 'list', 'cleanup', 'history'],
                      help='Comando a executar')
    
    parser.add_argument('file', nargs='?', help='Arquivo para processar')
    
    parser.add_argument('--version', '-v', type=int, 
                      help='Número da versão (para restore)')
    
    parser.add_argument('--keep', '-k', type=int, default=5,
                      help='Número de versões para manter (cleanup)')
    
    parser.add_argument('--backup-dir', '-b', default='.versions',
                      help='Diretório para backups')
    
    parser.add_argument('--base-dir', '-d', default='.',
                      help='Diretório base')
    
    args = parser.parse_args()
    
    # Inicializar gerenciador
    vm = VersionManager(base_dir=args.base_dir, backup_dir=args.backup_dir)
    
    if args.command == 'backup':
        if not args.file:
            print("❌ Arquivo necessário para backup")
            return 1
        
        backup_path = vm.create_backup(args.file)
        if backup_path:
            print(f"📦 Backup criado com sucesso: {backup_path}")
            return 0
        else:
            return 1
    
    elif args.command == 'restore':
        if not args.file or args.version is None:
            print("❌ Arquivo e versão necessários para restore")
            return 1
        
        if vm.restore_version(args.file, args.version):
            return 0
        else:
            return 1
    
    elif args.command == 'list':
        versions = vm.list_versions(args.file)
        
        if not versions:
            print("📋 Nenhuma versão encontrada")
            return 0
        
        print("📋 Versões disponíveis:")
        print()
        
        for file_path, version_info in versions.items():
            print(f"📄 {file_path}")
            print(f"   Versão atual: v{version_info.current_version:03d}")
            print(f"   Última modificação: {version_info.last_modified}")
            print(f"   Versões: {len(version_info.versions)}")
            print()
    
    elif args.command == 'cleanup':
        if not args.file:
            print("❌ Arquivo necessário para cleanup")
            return 1
        
        removed = vm.cleanup_old_versions(args.file, args.keep)
        print(f"🧹 Cleanup concluído. Versões removidas: {removed}")
        return 0
    
    elif args.command == 'history':
        if not args.file:
            print("❌ Arquivo necessário para history")
            return 1
        
        history = vm.get_file_history(args.file)
        
        if not history:
            print("📋 Nenhum histórico encontrado")
            return 0
        
        print(f"📋 Histórico de {args.file}:")
        print()
        
        for entry in history:
            print(f"v{entry['version']:03d} - {entry['modified']}")
            print(f"     Tamanho: {entry['size']} bytes")
            print(f"     Caminho: {entry['path']}")
            print()
    
    return 0


if __name__ == "__main__":
    exit(main())