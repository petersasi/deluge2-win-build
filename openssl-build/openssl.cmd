@pushd "%~dp0"
@call lib\printc green "This script is Copyright"
@call lib\printc green "2019-2020 Martin Hertz (mhertz-Denmark) user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\printc green "2020-2021 Peter Sasi user of the Deluge Forum https://forum.deluge-torrent.org/"
@call lib\initpath

@for /f %%i in ('git ls-remote --tags https://github.com/openssl/openssl ^| grep -E 'OpenSSL_[0-9]_[0-9]_[0-9][a-z]' ^| cut -d/ -f3 ^| tr -d "^{}" ^| cut -d_ -f2-4') do @set openSSLver=%%i
@call lib\printc info "Scraped latest OpenSSL version is: %openSSLver%"

@call lib\printc info "Download installer for it, tell curl to resume or skip download if possible"
@curl -C - -O https://slproweb.com/download/Win64OpenSSL-%openSSLver%.exe

@rem curl -C - -O https://mirror.firedaemon.com/OpenSSL/openssl-1.1.1h-dev.zip

@call lib\printc info "Install it on this OS"
@Win64OpenSSL-%openSSLver%.exe /dir="C:\OpenSSL-Win64" /verysilent

@call lib\printc info "Fish out the necessary DDLs from it and add them to our build overlay and the already built deluge folders (if any)"
copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\overlay\Lib\site-packages
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr /v dev') do copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\%%i\Lib\site-packages
for /f %%i in ('dir /b C:\deluge2\deluge-2* ^| findstr dev') do copy /y C:\OpenSSL-Win64\*.dll C:\deluge2\%%i\Lib\site-packages

@call lib\printc info "Not removing the downloaded installer so that we resume / do not download next time."
@rem del Win64OpenSSL-%openSSLver%.exe

@call lib\restorepath
@popd
