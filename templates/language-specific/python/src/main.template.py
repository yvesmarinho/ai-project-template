"""
{{project_name}} - Main Application Entry Point
{{description}}
"""

import os
import sys
from pathlib import Path

# Add src to Python path for imports
src_path = Path(__file__).parent.parent
sys.path.insert(0, str(src_path))

{{#if framework}}
{{#if (eq framework "fastapi")}}
import uvicorn
from fastapi import FastAPI
from {{package_name}}.app import create_app

def main():
    """Main entry point for FastAPI application."""
    app = create_app()
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    uvicorn.run(app, host=host, port=port, debug=debug)

{{/if}}
{{#if (eq framework "flask")}}
from {{package_name}}.app import create_app

def main():
    """Main entry point for Flask application."""
    app = create_app()
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 5000))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    app.run(host=host, port=port, debug=debug)

{{/if}}
{{#if (eq framework "django")}}
import django
from django.core.management import execute_from_command_line

def main():
    """Main entry point for Django application."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "{{package_name}}.settings")
    execute_from_command_line(sys.argv)

{{/if}}
{{#if (eq framework "none")}}
import logging
from {{package_name}}.core import run_application

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

def main():
    """Main entry point for the application."""
    logger = logging.getLogger(__name__)
    logger.info("Starting {{project_name}}...")
    
    try:
        run_application()
        logger.info("Application completed successfully")
    except Exception as e:
        logger.error(f"Application failed: {e}")
        sys.exit(1)

{{/if}}
{{else}}
import logging
import argparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

def main():
    """Main entry point for the application."""
    parser = argparse.ArgumentParser(description="{{description}}")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    logger = logging.getLogger(__name__)
    logger.info("Starting {{project_name}}...")
    
    # TODO: Implement your application logic here
    print("Hello from {{project_name}}!")
    
    logger.info("Application completed successfully")

{{/if}}

if __name__ == "__main__":
    main()