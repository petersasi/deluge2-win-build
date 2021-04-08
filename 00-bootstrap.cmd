@mkdir 99-Downloads
@cd 99-Downloads
@curl -C - -O http://repo.msys2.org/distrib/msys2-x86_64-latest.sfx.exe
@cd %~dp0
@99-Downloads\msys2-x86_64-latest.sfx.exe
@msys64\usr\bin\bash -lic "pacman -Syuu --noconfirm"
@msys64\usr\bin\bash -lic "pacman -Syuu --noconfirm"
@msys64\usr\bin\bash -lic "pacman -S diffutils patch git p7zip --noconfirm"
set PATH=%~dp0\msys64\usr\bin;%~dp0\msys64\usr\lib\p7zip;%PATH%
git clone https://github.com/petersasi/deluge2-win-build 90-gitRepo
mklink %~dp0\90-gitRepo\install_components.cmd %~dp0\01-install_components.cmd
rem %~dp0\01-install_components.cmd
