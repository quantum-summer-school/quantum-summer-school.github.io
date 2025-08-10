@echo off
setlocal enabledelayedexpansion

REM ========================================
REM Cross-Platform Conda Environment Creator - Windows Version 
REM ========================================
REM This script creates a conda environment with Python 3.10 and installs pip dependencies
REM Works by properly initializing Anaconda environment paths before running conda commands
REM Only requires conda/anaconda to be installed - no separate Python installation needed

REM ========================================
REM CONFIGURATION - EDIT THESE VARIABLES
REM ========================================

REM Environment name (change this if you want a different name)
set ENVIRONMENT_NAME=quantum_env

REM Python version (change if you need a different version)
set PYTHON_VERSION=3.10

REM Pip dependencies (add your packages here, separated by spaces)
set PIP_DEPENDENCIES=^
numpy ^
pandas ^
qiskit ^
matplotlib ^
qiskit-machine-learning ^
qiskit-aer ^
pennylane ^
pennylane-qiskit ^
seaborn ^
scqubits ^
ipyvuetify ^
sccircuitbuilder ^
qiskit-metal ^
pyside2 ^
geopandas ^
perceval-quandela




REM ========================================
REM SCRIPT LOGIC - DO NOT EDIT BELOW
REM ========================================

echo Creating conda environment with Python %PYTHON_VERSION%...
echo Environment name: %ENVIRONMENT_NAME%
echo.

REM Find Anaconda/Miniconda installation
set CONDA_ROOT=
set ACTIVATE_SCRIPT=

REM Check common installation paths
if exist "%USERPROFILE%\Anaconda3\Scripts\activate.bat" (
    set CONDA_ROOT=%USERPROFILE%\Anaconda3
    set ACTIVATE_SCRIPT=%USERPROFILE%\Anaconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

if exist "%USERPROFILE%\Miniconda3\Scripts\activate.bat" (
    set CONDA_ROOT=%USERPROFILE%\Miniconda3
    set ACTIVATE_SCRIPT=%USERPROFILE%\Miniconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

if exist "C:\ProgramData\Anaconda3\Scripts\activate.bat" (
    set CONDA_ROOT=C:\ProgramData\Anaconda3
    set ACTIVATE_SCRIPT=C:\ProgramData\Anaconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

if exist "C:\ProgramData\Miniconda3\Scripts\activate.bat" (
    set CONDA_ROOT=C:\ProgramData\Miniconda3
    set ACTIVATE_SCRIPT=C:\ProgramData\Miniconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

if exist "C:\Anaconda3\Scripts\activate.bat" (
    set CONDA_ROOT=C:\Anaconda3
    set ACTIVATE_SCRIPT=C:\Anaconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

if exist "C:\Miniconda3\Scripts\activate.bat" (
    set CONDA_ROOT=C:\Miniconda3
    set ACTIVATE_SCRIPT=C:\Miniconda3\Scripts\activate.bat
    goto CONDA_FOUND
)

REM If not found in common paths, try to find conda.exe in PATH
where conda.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    for /f "tokens=*" %%i in ('where conda.exe') do (
        set CONDA_EXE=%%i
        for %%j in ("!CONDA_EXE!") do set CONDA_ROOT=%%~dpj
        set CONDA_ROOT=!CONDA_ROOT:~0,-1!
        for %%k in ("!CONDA_ROOT!") do set CONDA_ROOT=%%~dpk
        set CONDA_ROOT=!CONDA_ROOT:~0,-1!
        set ACTIVATE_SCRIPT=!CONDA_ROOT!\Scripts\activate.bat
        if exist "!ACTIVATE_SCRIPT!" goto CONDA_FOUND
    )
)

echo ========================================
echo ERROR: Could not find Anaconda/Miniconda installation
echo ========================================
echo.
echo Conda is required to run this script but was not found on your system.
echo.
echo Please install either Anaconda or Miniconda first:
echo.
echo ** DOWNLOAD LINKS FOR WINDOWS **
echo.
echo 1. Anaconda Distribution (Recommended for beginners)
echo    - Full package with 300+ pre-installed packages
echo    - Includes Jupyter, Spyder, and other tools
echo    - Download from: https://www.anaconda.com/download
echo    - Look for "Download for Windows" button
echo.
echo ** INSTALLATION INSTRUCTIONS **
echo.
echo 1. Visit one of the download links above
echo 2. Sign in with an email so that you can download the .exe file
echo 3. Run the installer and follow the setup wizard
echo 4. Accept default settings (recommended)
echo 5. After installation, run this script again
echo.
echo ** TROUBLESHOOTING **
echo.
echo If you already have Anaconda/Miniconda installed:
echo - Make sure you are running this script from Anaconda Prompt
echo - Or check if conda is in your system PATH
echo.
echo Common installation paths checked:
echo   - %USERPROFILE%\Anaconda3
echo   - %USERPROFILE%\Miniconda3  
echo   - C:\ProgramData\Anaconda3
echo   - C:\ProgramData\Miniconda3
echo   - C:\Anaconda3
echo   - C:\Miniconda3
echo.
echo Press any key to open the download page in your browser...
pause >nul
start https://www.anaconda.com/download
exit /b 1

:CONDA_FOUND
echo Found conda installation at: %CONDA_ROOT%
echo Using activation script: %ACTIVATE_SCRIPT%
echo.

REM Initialize conda environment by calling the activation script
echo Initializing conda environment...
call "%ACTIVATE_SCRIPT%" "%CONDA_ROOT%"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to initialize conda environment
    pause
    exit /b 1
)

REM Check if environment already exists
call conda env list | findstr /C:"%ENVIRONMENT_NAME%" >nul
if %ERRORLEVEL%==0 (
    echo.
    echo Environment '%ENVIRONMENT_NAME%' already exists
    set /p OVERWRITE="Do you want to remove and recreate it? (y/N): "
    if /i "!OVERWRITE!"=="y" (
        echo Removing existing environment...
        call conda env remove -n %ENVIRONMENT_NAME% -y
        if !ERRORLEVEL! neq 0 (
            echo ERROR: Failed to remove existing environment
            pause
            exit /b 1
        )
    ) else (
        echo Operation cancelled
        pause
        exit /b 0
    )
)

REM Create the conda environment
echo Creating conda environment '%ENVIRONMENT_NAME%' with Python %PYTHON_VERSION%...
call conda create -n %ENVIRONMENT_NAME% python=%PYTHON_VERSION% pip -y
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to create conda environment
    pause
    exit /b 1
)

echo Environment created successfully

REM Install pip dependencies if any are specified
if defined PIP_DEPENDENCIES (
    echo.
    echo Installing pip dependencies...
    echo Dependencies: %PIP_DEPENDENCIES%
    
    REM Use conda run to install packages in the specific environment
    call conda run -n %ENVIRONMENT_NAME% pip install %PIP_DEPENDENCIES%
    if %ERRORLEVEL% neq 0 (
        echo WARNING: Some packages may have failed to install
        echo You can manually install them later using:
        echo   conda activate %ENVIRONMENT_NAME%
        echo   pip install [package_name]
    ) else (
        echo All dependencies installed successfully
    )
) else (
    echo No pip dependencies specified, skipping package installation
)

echo.
echo ========================================
echo Environment setup completed successfully!
echo ========================================
echo.
echo Environment name: %ENVIRONMENT_NAME%
echo Python version: %PYTHON_VERSION%
echo.
echo To activate your environment:
echo   conda activate %ENVIRONMENT_NAME%
echo.
echo To deactivate:
echo   conda deactivate
echo.
echo To remove the environment:
echo   conda env remove -n %ENVIRONMENT_NAME%
echo.
echo To list all environments:
echo   conda env list
echo.
pause