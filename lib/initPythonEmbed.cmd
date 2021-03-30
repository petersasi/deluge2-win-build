@if "%1x" EQU "x" echo Please specify target directory!&exit /B 1

mkdir "%~f1"
pushd "%~f1"
curl -L https://www.python.org/ftp/python/3.9.2/python-3.9.2-embed-amd64.zip|bsdtar xf -

set PATH=%~f1;%~f1\Scripts;%PATH%
echo import site>>"%~f1\python39._pth"

curl https://bootstrap.pypa.io/get-pip.py | .\python.exe
Scripts\pip install pygeoip requests windows-curses
popd
