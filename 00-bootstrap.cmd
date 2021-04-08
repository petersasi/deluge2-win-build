@pushd "%~dp0"

@rem This script is Copyright
@rem 2019-2020 Martin Hertz (mhertz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/
@rem 2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/

@mkdir 99-Downloads
@cd 99-Downloads
@curl -C - -O http://repo.msys2.org/distrib/msys2-x86_64-latest.sfx.exe
@cd %~dp0
@99-Downloads\msys2-x86_64-latest.sfx.exe

set PATH=%~dp0\msys64\usr\bin;%~dp0\msys64\usr\lib\p7zip;%PATH%
@bash -lic "pacman -Syuu --noconfirm"
@bash -lic "pacman -Syuu --noconfirm"
@bash -lic "pacman -S diffutils patch git p7zip --noconfirm"

@git clone https://github.com/petersasi/deluge2-win-build 90-gitRepo
@mklink %~dp0\90-gitRepo\install_components.cmd %~dp0\01-install_components.cmd
rem %~dp0\01-install_components.cmd

@popd
