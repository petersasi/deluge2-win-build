@call %~dp0\printc green "This script is Copyright 2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

@if "x%~1" EQU "x" @call %~dp0\printc error "First parameter should be folder to install Python into!" & exit /B 1

@for /f %%i in ('curl -s https://www.python.org/ ^| grep "Latest: " ^| cut -d/ -f5 ^| cut -d" " -f2 ^| tr -d "<"') do @set pythonVersion=%%i
@call %~dp0\printc info "Latest Python version scraped from web is %pythonVersion%"

@call %~dp0\printc info "Downloading Python %pythonVersion%, with curl -C - so that download is resumed / skipped."
@curl -C - -o c:\deluge2\python-%pythonVersion%-amd64.exe https://www.python.org/ftp/python/%pythonVersion%/python-%pythonVersion%-amd64.exe  || @call %~dp0\printc error "Python installer download failed" && exit /B 1

@call %~dp0\printc info "Installing it into %~1."
@c:\deluge2\python-%pythonVersion%-amd64.exe /quiet InstallAllUsers=1 Include_doc=0 Include_tcltk=0 Include_test=0 InstallLauncherAllUsers=0 Include_launcher=0 "TargetDir=%~1" || @call %~dp0\printc error "Python install failed!" && exit /B 1

@call %~dp0\printc info "Adding %~1 and %~1\Scripts to the PATH and also define PYTHONPATH."
@set PATH=%1;%1\Scripts;%PATH%
@set PYTHONPATH=%1

@call %~dp0\printc info "Upgrading pip and installing wheel to avoid build warnings."
@python -m pip install --upgrade pip wheel || @call %~dp0\printc error "Upgrading pip and installing wheel failed." && exit /B 1

@call lib\printc info "Copy the Python loaders with better windows integration into place"
@copy /y c:\deluge2\loaders\* "%PYTHONPATH%\Lib\site-packages\pip\_vendor\distlib"

@shift
@if "%1x" NEQ "x" (
	set PIPPARAMS=%1
) else @goto :completed
:loop
@shift
@if "%1x" NEQ "x" (
	set PIPPARAMS=%PIPPARAMS% %1
	@goto :loop
)
:completed
@call c:\deluge2\lib\printc info "Shift does not work on all-arguments, could only reference 2nd to 9th argument, so rather building a full list of parameters for pip:"
@call c:\deluge2\lib\printc value "%PIPPARAMS%"

@call c:\deluge2\lib\printc info "pip install the requested other modules."
@pip install %PIPPARAMS% || @call %~dp0\printc error "pip installing modules failed." && exit /B 1
