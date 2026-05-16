from fastapi import HTTPException, Security, status
from fastapi.security import APIKeyHeader
from app.config import get_settings

api_key_header = APIKeyHeader(name="X-ML-KEY", auto_error=False)


async def verify_ml_key(api_key: str = Security(api_key_header)) -> str:
    settings = get_settings()
    if not api_key or api_key != settings.ML_SERVICE_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_ML_KEY", "message": "Invalid or missing X-ML-KEY header"},
        )
    return api_key
