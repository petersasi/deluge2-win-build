@if "x%~1" EQU "x" @call %~dp0\printc error "First parameter should be folder of Python to uninstall!" & exit /B 1

@call %~dp0\printc info "Uninstalling Python."
@c:\deluge2\python-%pythonVersion%-amd64.exe /uninstall /quiet || @call %~dp0\printc error "Python uninstall failed!" && exit /B 1

@call %~dp0\printc info "Removing it's folder %1 in case ther was any leftover in it."
@if exist "%1" ( @rd /s /q %1 ) else @call %~dp0\printc error "No Python folder to remove" 
