from __future__ import annotations

import logging

from sqlalchemy import create_engine
from sqlalchemy.engine.url import make_url
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from .config import DATABASE_URL

logger = logging.getLogger("visionai")


class Base(DeclarativeBase):
    pass


def _socket_host(database_url: str) -> str | None:
    """Directorio de socket UNIX. psycopg 3 lo reconoce si empieza por /."""
    if database_url.startswith("sqlite"):
        return None
    host = make_url(database_url).query.get("host")
    if host and str(host).startswith("/"):
        return str(host)
    return None


def _connect_args(database_url: str) -> dict:
    if database_url.startswith("sqlite"):
        return {"check_same_thread": False}
    args: dict = {"connect_timeout": 10}
    socket_host = _socket_host(database_url)
    if socket_host:
        # La query ?host=/cloudsql/... ya es válida. Se repite aquí para que
        # no la pise ningún otro argumento al abrir el socket de Cloud SQL.
        args["host"] = socket_host
    return args


def safe_db_target() -> str:
    """Usuario, base y socket, sin la contraseña."""
    try:
        if DATABASE_URL.startswith("sqlite"):
            return "sqlite"
        url = make_url(DATABASE_URL)
        host = _socket_host(DATABASE_URL) or url.host or "(sin host)"
        return f"usuario={url.username} base={url.database} host={host}"
    except Exception:
        return "DATABASE_URL ilegible"


def log_db_error(exc: BaseException) -> None:
    original = getattr(exc, "orig", None) or exc.__cause__
    detail = original or exc
    text = str(detail)
    hint = ""
    if "socket" in text.lower() or "No such file" in text or "Connection refused" in text:
        hint = (
            " El directorio del socket no está montado en el contenedor."
            " En Cloud Run → Conexiones, el nombre de Cloud SQL tiene que ser"
            " idéntico al host de DATABASE_URL."
        )
    logger.error("PostgreSQL rechazó la conexión. %s | %s: %s%s", safe_db_target(), type(detail).__name__, detail, hint)
    logger.exception("Traceback PostgreSQL")


engine = create_engine(DATABASE_URL, connect_args=_connect_args(DATABASE_URL), pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    except SQLAlchemyError as exc:
        db.rollback()
        log_db_error(exc)
        raise
    finally:
        db.close()
