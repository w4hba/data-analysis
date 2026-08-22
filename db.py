"""Shared MySQL connection for the portfolio's Python scripts.

Credentials come from db.local.cnf at the repo root (gitignored) if present,
otherwise from environment variables, with local-dev defaults. No password is
hardcoded here. To run these scripts yourself, either create db.local.cnf with a
[client] section or export MYSQL_PASSWORD (and optionally MYSQL_USER/HOST/DB).
"""
from __future__ import annotations

import configparser
import os
import pathlib
from urllib.parse import quote_plus

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine

REPO_ROOT = pathlib.Path(__file__).resolve().parent
CNF = REPO_ROOT / "db.local.cnf"


def _params() -> tuple[str, str, str, str]:
    host, user, password, db = "127.0.0.1", "analyst", None, "portfolio"
    if CNF.exists():
        cp = configparser.ConfigParser()
        cp.read(CNF)
        c = cp["client"]
        host = c.get("host", host)
        user = c.get("user", user)
        password = c.get("password", password)
        db = c.get("database", db)
    host = os.environ.get("MYSQL_HOST", host)
    user = os.environ.get("MYSQL_USER", user)
    password = os.environ.get("MYSQL_PASSWORD", password)
    db = os.environ.get("MYSQL_DB", db)
    if not password:
        raise SystemExit(
            "No database password found. Create db.local.cnf ([client] section) "
            "or set MYSQL_PASSWORD in the environment."
        )
    return host, user, password, db


def get_engine() -> Engine:
    host, user, password, db = _params()
    url = f"mysql+pymysql://{user}:{quote_plus(password)}@{host}/{db}?charset=utf8mb4"
    return create_engine(url)
