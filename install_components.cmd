@pushd "%~dp0"
@call lib\printc green "This script is Copyright"
@call lib\printc green "2019-2020 Martin Hertz (mhertz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\printc green "2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"

rem added -C - so that it is resumed / not redownloaded
curl -C - -O http://repo.msys2.org/distrib/msys2-x86_64-latest.tar.xz
rem cannot yet use the MSYS2 7zip, but at least no immediate tar file
"%programfiles%\7-Zip\7z.exe" x -so msys2-x86_64-latest.tar.xz | "%programfiles%\7-Zip\7z.exe" x -si -ttar -oC:
C:\msys64\usr\bin\bash -lic "pacman -Syu --noconfirm"
C:\msys64\usr\bin\bash -lic "pacman -Syu --noconfirm"
C:\msys64\usr\bin\bash -lic "pacman -S diffutils patch git p7zip --noconfirm"

rem added -C - so that it is resumed / not redownloaded
curl -C - -LO http://prdownloads.sourceforge.net/nsis/nsis-3.05-setup.exe
nsis-3.05-setup.exe /S

rem added -C - so that it is resumed / not redownloaded
curl.exe -C - -kO https://nsis.sourceforge.io/mediawiki/images/1/18/NsProcess.zip
"%programfiles%\7-Zip\7z.exe" x NsProcess.zip -onsprocess
move nsprocess\Plugin\nsProcessW.dll "%programfiles(x86)%\NSIS\Plugins\x86-unicode\nsProcess.dll"
move nsprocess\Include\nsProcess.nsh "%programfiles(x86)%\NSIS\Include"

rem added -C - so that it is resumed / not redownloaded
curl.exe -C - -k https://git.landicorp.com/electron-downloadtool/electron-downloadtool/-/raw/5da62a7d62329bd9afe7a1bfda3f759d6bc04c80/node_modules/electron-builder/templates/nsis/include/StrContains.nsh > "%programfiles(x86)%\NSIS\Include\strContains.nsh"

rem added -C - so that it is resumed / not redownloaded
curl.exe -C - -kO https://download.visualstudio.microsoft.com/download/pr/68d6b204-9df0-4fcc-abcc-08ee0eff9cb2/0b833c703ae7532e54db2d1926e2c3d2e29a7c053358f8c635498ab25bb8c590/vs_BuildTools.exe
vs_buildtools.exe --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --wait

rem do not remove these installs so this script can later resume download and reuse them if already downloaded
rem del auto-install.js msys2-x86_64-latest.tar* Win64OpenSSL-1_1_1g.exe nsis-3.05-setup.exe NsProcess.zip vs_BuildTools.exe

rd /s /q nsprocess
rd /s /q nsprocess

call lib\createlinks.cmd
popd