@call lib\printc green "This script is Copyright 2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

@call %~dp0\printc info "Remove folders and files not needed."

@if "x%~1" EQU "x" @call %~dp0\printc error "First parameter should be the name of the file that contains the regexps matching the files to remove!" & exit /B 1
@if "x%~2" EQU "x" @call %~dp0\printc error "Second parameter should be the name of the file that contains the folders to remove!" & exit /B 1
@if "x%~3" EQU "x" @call %~dp0\printc error "Third paramter should be the base path under which to remove!" & exit /B 1

@call %~dp0\printc info "Matching regular expressions to the list of files..."
@c:\msys64\usr\bin\find.exe "%~3" -type f >%~dp0\filesInDir.lst
@mklink %~dp0\filesUnusedRegExps.lst "%~f1"

@c:\msys64\usr\bin\bash.exe -c "/c/deluge2/lib/batchGrep.sh /c/deluge2/lib/filesInDir.lst /c/deluge2/lib/filesUnusedRegExps.lst -i"|c:\msys64\usr\bin\sort.exe -u|c:\msys64\usr\bin\tr.exe '/' '\\' > %~dp0\toDel.lst

@if "%~4" NEQ "--dry" @(
	@for /f "delims=" %%i in ( %~dp0\toDel.lst ) do @del /f /q "%%i" || @call %~dp0\printc error "Cannot delete: %%i"
	@del %~dp0\filesInDir.lst
	@del %~dp0\filesUnusedRegExps.lst
	@del %~dp0\toDel.lst
) else (
	@call %~dp0\printc info "Please find the files that would have been deleted in %~dp0\toDel.lst"
)

@call %~dp0\printc info "Removing folders specified."
@for /f "delims=" %%i in ( %~2 ) do @(
	@if "%~4" NEQ "--dry" @(
		@rd /s /q "%~3\%%i" || @call %~dp0\printc error "Cannot delete: %~3\%%i"
	) else @(
		@echo rd /s /q "%~3\%%i">>%~dp0\dirDel.bat
	)
)
