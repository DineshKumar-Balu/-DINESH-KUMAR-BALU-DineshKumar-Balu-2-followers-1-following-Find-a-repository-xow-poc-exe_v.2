@echo off
setlocal

:: Set path to portable Python
set "python_path=%cd%\PortablePython\Python312"
set "python_exe=%python_path%\python.exe"

:: Function to check if Python is available
:CheckPython
if not exist "%python_exe%" (
    echo Python not found at %python_exe%. Downloading and installing...
    mkdir "%python_path%"
    call :DownloadPython
) else (
    echo Python found at %python_exe%.
    goto :PostDownload
)

:: Function to download and extract portable Python
:DownloadPython
echo Downloading portable Python...
powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.12.0/python-3.12.0-embed-amd64.zip -OutFile python-3.12.0-embed-amd64.zip"
if %errorlevel% neq 0 (
    echo Failed to download Python.
    exit /b %errorlevel%
)
echo Extracting portable Python...
powershell -Command "Expand-Archive -Path python-3.12.0-embed-amd64.zip -DestinationPath %python_path% -Force"
if %errorlevel% neq 0 (
    echo Failed to extract Python.
    exit /b %errorlevel%
)
echo Python downloaded and extracted successfully.
del python-3.12.0-embed-amd64.zip
goto :PostDownload

:PostDownload
:: Check if virtual environment exists
if not exist .\env (
    echo Creating virtual environment...
    "%python_exe%" -m venv .\env
    if %errorlevel% neq 0 (
        echo Failed to create virtual environment.
        exit /b %errorlevel%
    )
)

:: Activate the virtual environment
call .\env\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo Failed to activate virtual environment.
    exit /b %errorlevel%
)

:: Ensure using the correct python executable in the virtual environment
set "venv_python=%cd%\env\Scripts\python.exe"
set "venv_pip=%cd%\env\Scripts\pip.exe"

:: Upgrade pip
echo Upgrading pip...
"%venv_python%" -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo Failed to upgrade pip.
    exit /b %errorlevel%
)

:: Install dependencies
echo Installing dependencies...
"%venv_pip%" install -r requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install dependencies.
    exit /b %errorlevel%
)

:: Run the launcher.py script
echo Running launcher.py...
"%venv_python%" launcher.py
if %errorlevel% neq 0 (
    echo Failed to run launcher.py.
    exit /b %errorlevel%
)

echo Setup and run completed successfully.
endlocal
pause
goto :EOF
