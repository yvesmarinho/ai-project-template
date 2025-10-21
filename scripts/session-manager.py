#!/usr/bin/env python3
"""
AI Project Template - Session Management System
Sistema de tracking e gerenciamento de sessões de desenvolvimento.
Inspirado em: enterprise-project-model session tracking patterns
"""

import os
import json
import yaml
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict, field
import uuid
import argparse

@dataclass
class SessionAction:
    """Ação executada durante a sessão"""
    timestamp: str
    action_type: str
    description: str
    details: Dict[str, Any] = field(default_factory=dict)
    status: str = "completed"  # completed, failed, skipped
    duration_seconds: Optional[float] = None

@dataclass
class SessionInfo:
    """Informações completas da sessão"""
    session_id: str
    start_time: str
    project_path: str
    end_time: Optional[str] = None
    template_version: str = "1.0.0"
    user_name: str = ""
    session_type: str = "development"  # development, build, test, deploy
    status: str = "active"  # active, completed, failed, paused
    actions: List[SessionAction] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def duration_minutes(self) -> Optional[float]:
        """Calcular duração da sessão em minutos"""
        if not self.end_time:
            return None
        
        start = datetime.fromisoformat(self.start_time.replace('Z', '+00:00'))
        end = datetime.fromisoformat(self.end_time.replace('Z', '+00:00'))
        return (end - start).total_seconds() / 60

class SessionManager:
    """Gerenciador de sessões do AI Project Template"""
    
    def __init__(self, project_path: str = None):
        """Inicializar gerenciador de sessão"""
        self.project_path = Path(project_path or os.getcwd()).resolve()
        self.session_dir = self.project_path / ".ai-template"
        self.session_dir.mkdir(exist_ok=True)
        
        self.session_file = self.session_dir / ".session-current"
        self.history_dir = self.session_dir / "history"
        self.history_dir.mkdir(exist_ok=True)
        
        self.reports_dir = self.project_path / "reports"
        self.reports_dir.mkdir(exist_ok=True)
        
        self.current_session: Optional[SessionInfo] = None
    
    def start_session(self, session_type: str = "development", user_name: str = "") -> str:
        """Iniciar nova sessão"""
        # Finalizar sessão anterior se existir
        if self.has_active_session():
            print("⚠️  Finalizando sessão anterior...")
            self.end_session()
        
        # Criar nova sessão
        session_id = str(uuid.uuid4())[:8]
        timestamp = datetime.now(timezone.utc).isoformat()
        
        self.current_session = SessionInfo(
            session_id=session_id,
            start_time=timestamp,
            project_path=str(self.project_path),
            user_name=user_name or os.environ.get('USER', 'unknown'),
            session_type=session_type,
            metadata={
                'template_version': '1.0.0',
                'python_version': f"{os.sys.version_info.major}.{os.sys.version_info.minor}",
                'working_directory': str(self.project_path),
                'environment': dict(os.environ)
            }
        )
        
        # Salvar sessão atual
        self._save_current_session()
        
        print(f"🚀 Sessão iniciada: {session_id} ({session_type})")
        return session_id
    
    def end_session(self, status: str = "completed") -> Optional[str]:
        """Finalizar sessão atual"""
        if not self.current_session:
            print("❌ Nenhuma sessão ativa encontrada")
            return None
        
        # Atualizar informações de fim
        self.current_session.end_time = datetime.now(timezone.utc).isoformat()
        self.current_session.status = status
        
        # Salvar no histórico
        history_file = self.history_dir / f"session-{self.current_session.session_id}.json"
        with open(history_file, 'w', encoding='utf-8') as f:
            json.dump(asdict(self.current_session), f, indent=2, ensure_ascii=False)
        
        # Gerar relatório
        self._generate_session_report()
        
        # Limpar sessão atual
        session_id = self.current_session.session_id
        duration = self.current_session.duration_minutes()
        
        if self.session_file.exists():
            self.session_file.unlink()
        
        self.current_session = None
        
        print(f"✅ Sessão finalizada: {session_id}")
        if duration:
            print(f"   ⏱️  Duração: {duration:.1f} minutos")
        
        return session_id
    
    def log_action(self, action_type: str, description: str, 
                   details: Dict[str, Any] = None, status: str = "completed") -> None:
        """Registrar ação na sessão atual"""
        if not self.current_session:
            print("⚠️  Nenhuma sessão ativa. Iniciando sessão automaticamente...")
            self.start_session()
        
        action = SessionAction(
            timestamp=datetime.now(timezone.utc).isoformat(),
            action_type=action_type,
            description=description,
            details=details or {},
            status=status
        )
        
        self.current_session.actions.append(action)
        self._save_current_session()
        
        # Log visual
        status_emoji = {"completed": "✅", "failed": "❌", "skipped": "⏭️ "}.get(status, "📝")
        print(f"{status_emoji} {action_type}: {description}")
    
    def has_active_session(self) -> bool:
        """Verificar se existe sessão ativa"""
        return self.session_file.exists()
    
    def load_current_session(self) -> Optional[SessionInfo]:
        """Carregar sessão atual do arquivo"""
        if not self.session_file.exists():
            return None
        
        try:
            with open(self.session_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.current_session = SessionInfo(**data)
                return self.current_session
        except (json.JSONDecodeError, TypeError) as e:
            print(f"⚠️  Erro ao carregar sessão: {e}")
            return None
    
    def get_session_status(self) -> Dict[str, Any]:
        """Obter status da sessão atual"""
        if not self.current_session:
            self.load_current_session()
        
        if not self.current_session:
            return {
                'active': False,
                'message': 'Nenhuma sessão ativa'
            }
        
        current_time = datetime.now(timezone.utc)
        start_time = datetime.fromisoformat(self.current_session.start_time.replace('Z', '+00:00'))
        duration_minutes = (current_time - start_time).total_seconds() / 60
        
        return {
            'active': True,
            'session_id': self.current_session.session_id,
            'type': self.current_session.session_type,
            'duration_minutes': round(duration_minutes, 1),
            'actions_count': len(self.current_session.actions),
            'status': self.current_session.status,
            'user': self.current_session.user_name
        }
    
    def list_recent_sessions(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Listar sessões recentes"""
        sessions = []
        
        for session_file in sorted(self.history_dir.glob("session-*.json"), 
                                 key=lambda x: x.stat().st_mtime, reverse=True)[:limit]:
            try:
                with open(session_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    sessions.append({
                        'session_id': data['session_id'],
                        'start_time': data['start_time'],
                        'end_time': data.get('end_time'),
                        'session_type': data['session_type'],
                        'status': data['status'],
                        'actions_count': len(data.get('actions', [])),
                        'duration_minutes': SessionInfo(**data).duration_minutes()
                    })
            except (json.JSONDecodeError, KeyError):
                continue
        
        return sessions
    
    def _save_current_session(self) -> None:
        """Salvar sessão atual no arquivo"""
        if not self.current_session:
            return
        
        with open(self.session_file, 'w', encoding='utf-8') as f:
            json.dump(asdict(self.current_session), f, indent=2, ensure_ascii=False)
    
    def _generate_session_report(self) -> None:
        """Gerar relatório da sessão"""
        if not self.current_session:
            return
        
        # Nome do arquivo de relatório
        start_date = datetime.fromisoformat(self.current_session.start_time.replace('Z', '+00:00'))
        report_name = f"SESSION-REPORT-{start_date.strftime('%Y-%m-%d-%H%M')}.md"
        report_file = self.reports_dir / report_name
        
        # Gerar conteúdo do relatório
        duration = self.current_session.duration_minutes()
        
        report_content = f"""# Session Report - {self.current_session.session_id}

## 📋 Session Information
- **Session ID**: {self.current_session.session_id}
- **Type**: {self.current_session.session_type}
- **User**: {self.current_session.user_name}
- **Status**: {self.current_session.status}
- **Start Time**: {self.current_session.start_time}
- **End Time**: {self.current_session.end_time}
- **Duration**: {duration:.1f} minutes" if duration else "N/A"
- **Project Path**: {self.current_session.project_path}

## 🔄 Actions Performed ({len(self.current_session.actions)} total)

"""
        
        # Agrupar ações por tipo
        actions_by_type = {}
        for action in self.current_session.actions:
            action_type = action.action_type
            if action_type not in actions_by_type:
                actions_by_type[action_type] = []
            actions_by_type[action_type].append(action)
        
        for action_type, actions in actions_by_type.items():
            report_content += f"### {action_type.replace('_', ' ').title()}\n\n"
            
            for action in actions:
                status_emoji = {"completed": "✅", "failed": "❌", "skipped": "⏭️"}.get(action.status, "📝")
                timestamp = datetime.fromisoformat(action.timestamp.replace('Z', '+00:00')).strftime('%H:%M:%S')
                
                report_content += f"- {status_emoji} **{timestamp}**: {action.description}\n"
                
                if action.details:
                    for key, value in action.details.items():
                        if isinstance(value, (list, dict)):
                            report_content += f"  - {key}: {json.dumps(value, ensure_ascii=False)}\n"
                        else:
                            report_content += f"  - {key}: {value}\n"
                
                report_content += "\n"
        
        # Estatísticas
        completed_actions = [a for a in self.current_session.actions if a.status == "completed"]
        failed_actions = [a for a in self.current_session.actions if a.status == "failed"]
        
        report_content += f"""## 📊 Statistics

- **Total Actions**: {len(self.current_session.actions)}
- **Completed**: {len(completed_actions)}
- **Failed**: {len(failed_actions)}
- **Success Rate**: {len(completed_actions)/len(self.current_session.actions)*100:.1f}%" if self.current_session.actions else "N/A"

## 🔧 Environment

- **Template Version**: {self.current_session.metadata.get('template_version', 'N/A')}
- **Python Version**: {self.current_session.metadata.get('python_version', 'N/A')}
- **Working Directory**: {self.current_session.metadata.get('working_directory', 'N/A')}

---
*Report generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
        
        # Salvar relatório
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report_content)
        
        print(f"📄 Relatório gerado: {report_file}")

def main():
    """CLI para gerenciamento de sessões"""
    parser = argparse.ArgumentParser(description='AI Project Template - Session Manager')
    parser.add_argument('--project-path', '-p', help='Caminho do projeto')
    
    subparsers = parser.add_subparsers(dest='command', help='Comandos disponíveis')
    
    # Comando start
    start_parser = subparsers.add_parser('start', help='Iniciar nova sessão')
    start_parser.add_argument('--type', choices=['development', 'build', 'test', 'deploy'],
                             default='development', help='Tipo da sessão')
    start_parser.add_argument('--user', help='Nome do usuário')
    
    # Comando end
    subparsers.add_parser('end', help='Finalizar sessão atual')
    
    # Comando status
    subparsers.add_parser('status', help='Mostrar status da sessão atual')
    
    # Comando history
    history_parser = subparsers.add_parser('history', help='Mostrar histórico de sessões')
    history_parser.add_argument('--limit', type=int, default=10, help='Número de sessões a mostrar')
    
    # Comando log
    log_parser = subparsers.add_parser('log', help='Registrar ação na sessão')
    log_parser.add_argument('type', help='Tipo da ação')
    log_parser.add_argument('description', help='Descrição da ação')
    log_parser.add_argument('--status', choices=['completed', 'failed', 'skipped'],
                           default='completed', help='Status da ação')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return 1
    
    # Inicializar gerenciador
    manager = SessionManager(args.project_path)
    
    # Executar comando
    if args.command == 'start':
        manager.start_session(args.type, args.user or "")
    
    elif args.command == 'end':
        manager.end_session()
    
    elif args.command == 'status':
        status = manager.get_session_status()
        if status['active']:
            print(f"🟢 Sessão ativa: {status['session_id']}")
            print(f"   📋 Tipo: {status['type']}")
            print(f"   👤 Usuário: {status['user']}")
            print(f"   ⏱️  Duração: {status['duration_minutes']} minutos")
            print(f"   🔄 Ações: {status['actions_count']}")
        else:
            print("🔴 Nenhuma sessão ativa")
    
    elif args.command == 'history':
        sessions = manager.list_recent_sessions(args.limit)
        if sessions:
            print(f"📋 Últimas {len(sessions)} sessões:")
            for session in sessions:
                duration = f"{session['duration_minutes']:.1f}min" if session['duration_minutes'] else "N/A"
                print(f"   {session['session_id']} | {session['session_type']} | {duration} | {session['actions_count']} ações")
        else:
            print("📝 Nenhuma sessão encontrada no histórico")
    
    elif args.command == 'log':
        manager.log_action(args.type, args.description, status=args.status)
    
    return 0

if __name__ == '__main__':
    exit(main())