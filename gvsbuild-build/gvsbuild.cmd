@rem This script is Copyright 
@rem 2019-2020 Martin Herz (mherz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@cd "%~dp0"
@call lib\printc info "Changed to the directory of this script"
@call lib\initpath C:\gtk-build\gtk\x64\release\bin

@call lib\printc info "Setting build environment values."
@set DOWNLOAD_DIR=C:\gtk-cache
@set MSYSPATH=C:\msys64\usr\bin
@set platform=x64
@set VS_VER=16
@set VS_VCVARS=14.25
@set arch=amd64
@set VSCMD_DEBUG=1

@call lib\initPython.cmd C:\python || @call lib\printc error "Python install failed!" && exit /B 1

@call lib\printc info "Cloning gvsbuild git"
@git clone https://github.com/wingtk/gvsbuild C:\gtk-build\github\gvsbuild

@call lib\printc info "Hand-patching gvsbuild git using sed"
@cd C:\gtk-build\github\gvsbuild
@copy "%~dp0\win32.patch" patches\gtk3-24 || @call %~dp0\lib\printc error "Copying the CSS patch for win32 failed!" && exit /B 1
@sed -i 's/gtk3_24(Tarball/gtk3_24(GitRepo/' gvsbuild\projects.py || @call %~dp0\lib\printc error "Hand-patching gvsbuild\projects.py failed!" && exit /B 1
@sed -i "/prj_dir='gtk3-24',/{n;N;d}" gvsbuild\projects.py || @call %~dp0\lib\printc error "Hand-patching gvsbuild\projects.py failed!" && exit /B 1
@sed -i "/'gtk_update_icon_cache.patch',/a\                'win32.patch'," gvsbuild\projects.py || @call %~dp0\lib\printc error "Hand-patching gvsbuild\projects.py failed!" && exit /B 1
@sed -i "/prj_dir='gtk3-24',/a\            repo_url = 'https:\/\/gitlab.gnome.org\/GNOME\/gtk.git',\n            fetch_submodules = False,\n            tag = 'gtk-3-24'," gvsbuild\projects.py || @call %~dp0\lib\printc error "Hand-patching gvsbuild\projects.py failed!" && exit /B 1

@call %~dp0\lib\printc info "Starting gvsbuild"
@python build.py -d build --gtk3-ver=3.24 --archives-download-dir=%DOWNLOAD_DIR% --vs-ver=%VS_VER% --platform=x64 --vs-install-path="%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --python-dir=%PYTHONPATH% -k --enable-gi --py-wheel --python-ver=%pythonVersion% enchant gtk3-full pycairo pygobject lz4 --skip gtksourceview3,emeus,clutter --capture-out --print-out || @call %~dp0\lib\printc error "GTK build failed!" && exit /B 1

@cd "%~dp0"
@call lib\removePython.cmd %PYTHONPATH%

@call lib\printc info "Save the python wheels built into the deluge-build folder."
@del C:\deluge2\deluge-build\pycairo-*-win_amd64.whl || @call lib\printc error "No pycairo in deluge-build to delete!"
@del C:\deluge2\deluge-build\PyGObject-*-win_amd64.whl || @call lib\printc error "No PyGObject in deluge-build to delete!"
@move /y C:\gtk-build\gtk\x64\release\python\*.whl C:\deluge2\deluge-build || @call lib\printc error "Moving wheels failed!" && exit /B 1

@call lib\printc info "Saving the more detailed gvsbuild log to the %~dp0 folder"
@move /y C:\gtk-build\logs\gvsbuild-log.txt C:\deluge2\gvsbuild-build || @call lib\printc error "Moving build log failed!" && exit /B 1

@call lib\cleanfilesfolders.cmd "%~dp0FilesUnusedList.txt" "%~dp0FoldersUnusedList.txt" C:\gtk-build\gtk\x64\release

@call lib\printc info "Copy additional files form not produced by gvsbuild into the completed build."
@copy c:\deluge2\gvsbuild-build\additional\msvcp140.dll C:\gtk-build\gtk\x64\release\bin || @call lib\printc error "Moving msvcp140.dll failed!" && exit /B 1
@copy c:\deluge2\gvsbuild-build\additional\settings.ini C:\gtk-build\gtk\x64\release\etc\gtk-3.0 || @call lib\printc error "Moving settings.ini failed!" && exit /B 1
@xcopy /ehqi c:\deluge2\gvsbuild-build\additional\win32x C:\gtk-build\gtk\x64\release\share\themes\win32x

@call lib\printc info "Removing the old overlay\data and moving the merged build in its place."
@rd /s /q  C:\deluge2\overlay\data || @call lib\printc error "Removing old overlay\data folder failed!" && exit /B 1
@move C:\gtk-build\gtk\x64\release C:\deluge2\overlay\data || @call lib\printc error "Moving merged build folder to overlay failed!" && exit /B 1

@call lib\printc info "Removing the GTK build folder"
@rd /s /q C:\gtk-build || @call lib\printc error "Removing the GTK build folder failed!" && exit /B 1

@call lib\printc info "Replacing the overlay\data in possibly existing deluge dev and stable builds with the new one."
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do rd /s /q C:\deluge2\%%i\data
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do rd /s /q C:\deluge2\%%i\data
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do xcopy /ehq C:\deluge2\overlay\data C:\deluge2\%%i\data\
@for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do xcopy /ehq C:\deluge2\overlay\data C:\deluge2\%%i\data\

@call lib\restorepath
