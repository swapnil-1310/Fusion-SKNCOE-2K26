@echo off
setlocal
pushd "%~dp0"

set "PROJECT_PYTHON=%~dp0.venv\Scripts\python.exe"

if not exist "%PROJECT_PYTHON%" (
    echo ERROR: Project virtual environment not found.
    echo Create it with: py -3.11 -m venv .venv
    echo Then install dependencies with: .venv\Scripts\python.exe -m pip install -r requirements.txt
    popd
    exit /b 1
)

echo Checking project Python version...
"%PROJECT_PYTHON%" -c "import sys; print('Python', sys.version.split()[0]); sys.exit(0 if sys.version_info[:2] == (3, 11) else 1)"
if errorlevel 1 (
    echo ERROR: This project expects Python 3.11.x in .venv.
    popd
    exit /b 1
)

echo Checking installed package consistency...
"%PROJECT_PYTHON%" -m pip check >nul 2>&1
if errorlevel 1 (
    echo Note: Some packages report optional dependency notices.
)

echo Checking core required imports...
"%PROJECT_PYTHON%" -c "import fastapi, uvicorn, pydantic_settings, multipart, cv2, qrcode, webauthn, PIL, reportlab; print('FastAPI', fastapi.__version__); print('Uvicorn', uvicorn.__version__); print('OpenCV', cv2.__version__); print('WebAuthn', webauthn.__version__); print('Pillow', PIL.__version__)"
if errorlevel 1 (
    echo ERROR: One or more core required imports failed.
    popd
    exit /b 1
)

"%PROJECT_PYTHON%" -c "import torch, mediapipe, transformers, faster_whisper, av" >nul 2>&1
if errorlevel 1 (
    echo Note: Local PyTorch and Whisper models are not installed.
    echo The app will run in serverless simulation mode [Vercel ready].
    echo For local ML inference weights, run: pip install -r requirements-ml.txt
) else (
    echo Full local ML model libraries are installed.
)

echo.
echo Core project requirements are installed and ready to run.
popd
exit /b 0
