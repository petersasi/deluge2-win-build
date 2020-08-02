# deluge2-win-build
A set of scripts to prepare prerequisites for and build Deluge2 and it's prerequisites for Windows

IMPORTANT!
The current release folder for these builds (the "Deluge2 Unofficial Installer for Windows" Google Drive Folder) contains several older builds with older build logic and library versions just in case you would find it useful to go back. 

PLEASE switch to List View (top right corner icon) to see the file dates and download the _latest_ version unless you know what you are doing! 

Your maintainer mostly uses the latest, non-portable dev version with thin client and daemon mode on Windows 10 with the Adwaita-dark theme, so consider that combination the best tested.

BUILDING
To build Deluge2 for windows use the scripts in the below order. first install the prerequisites: (install_components.cmd)
1.	7zip
2.	MSYS2
3.	NullSoft Scriptable Intstaller System
4.	NSprocess plugin for NSIS for process control
5.	StrContains plugin for NSIS
6.	Microsoft Visual Studio 2019
Using openssl-build\openssl.cmd
7.	Latest OpenSSL release
And build: 
1.	GTK-3 using wingtk/gvsbuild (gvsbuild-build\gvsbuild.cmd)
2.	Libtorrent, 3 flavours, including and using Boost and it's B2 build system and the latest Python version (libtorrent-build\{lt-RC_1_2.cmd,lt-RC_1_1.cmd,lt-1.2.3.cmd})
3.	Deluge: the latest release version and the latest dev version. Including and using the latest Python version. (deluge-build\{deluge-dev.cmd,deluge-stable.cmd})
4.	Installers for the above (installer-build\{installer-both.cmd,installer-dev.cmd,installer-stable.cmd})

The current set of scripts is a work in progress lacking several flavours of cleanup, see TODO at the end. Priority is given to features so the cleanup is not yet finished, patches / PRs
are welcome! ;)

CHANGE LOG:

2-Aug-2020 - publish build scripts and guide at on github

1.	Find the scripts and guide here: https://github.com/petersasi/deluge2-win-build

1-Aug-2020 - portable install fix and Latest GTK3

1.	Fixed the portability move of the profile folder into the install dir.
2.	Built GTK 3.24.21 into the new install.

31-Jul-2020 - 34% smaller, Win integration, portability&build fixes, new vers

1.	One third smaller installer and Installed Deluge folder through profiling
	of deluge, deluged, deluge-web and deluge-console using Process Monitor
	and removing the files not used according to the profiling.
	EXCEPTIONS: .exe files; folders that have 'locale' or 'hazmat' in their
	name.
	PLEASE test and let me know if I have removed too much!!!
2.	Better Windows integration through alternative loaders, courtesy of MHerz:
	- Now can pin deluge on taskbar
	- shows only one deluge / deluged / deluge-web process, python[w].exe is
	  embedded.
	- loader has Deluge icons
3.	Updated LibTorrent to 1.2.8 released 30-Jul-2020.
4.	Updated to Python to version 3.8.5 released on 20-Jul-2020.
5.	Portable install fix to put the deluge profile folder as well in the data
	subfolder of the deluge install folder in case of portable installations,
	courtesy of MHerz.
6.	Updated te GeoIP database and added the automated GeoIP database update to
	the build system, courtesy of MHerz.
7.	Fixed a torrentmanager.py patch in the stable deluge-build.
8.	Install wheel using pip during deluge-build to avoid build warnings.
9.	Removed LIBTORRENT_REVISION from the file names as it seems useless. Other
	installer name fixes.
10.	Stopped copying the vcvarsall.bat around to make the LibTorrent build happy
	using proper build commands.
11.	Added up to date LibTorrent-ChangeLog.txt, GTK-3.24-ChangeLog.txt and
	Python-ChangeLog.txt to the "Deluge2 Unofficial Installer for Windows"
	folder to make it easy for you to check what fixes are included in the new
	version.
12.	Moved earlier releases to an Archive folder.

21-Jun-2020 - make deluge-console.exe work for non-interactive commands

1.	Created a patch to swallow the AttributeError because of not having the
	signal SIGWINCH on Windows in Python windows-curses. Now you can run:
	deluge-console.exe status
	deluge-console.exe info 
	etc.
	https://dev.deluge-torrent.org/ticket/3409 is the ticket submitted with a
	patch for this.
2.	Created a patch to replace the "Deluge-console does not run in interactive
	mode on Windows." message and exiting. Instead we just log a debug message
	and carry on. Now the interactive UI starts but does not accept any input.
	The log is full of a twister error for win32select. I am stuck here, will
	have to ask for the help of the devs.
	https://dev.deluge-torrent.org/ticket/3410 is the ticket submitted with a
	patch for this.
3.	Published patches in a folder on the download site.

20-Jun-2020	- revive deluge-console, updated Deluge patch, reduced build size,
			enhanced build scripts, ChangeLog

1.	The default ncurses in Python is not supported (and does not work) on
	Windows. Try to include windows-curses 2.1.0 in the hope to revive that -
	it should have a hack to make it work (thanks for the report @mystikfox!)
2. PR by djlegolas regarding ignoring untrue libtorrent 1.2.x tracker errors
	from UIs was updated - replaced the old URL in the
	deluge-build\deluge-{dev,stable}.cmd scripts
3.	Refactored the folder cleanup logic in deluge-build\deluge-{dev,stable}.cmd
	scripts to use a list from a text file instead of the previously 12 later
	much more lines of "rd /s /q" ("%programfiles%\deluge\" added to all)
4.	First slimming of the installer by profiling to find files never touched,
	removed - this round only strips away complete folders unused:
	- test / tests / unittest folders: 18.2MB
	- demos folders: 0.9MB 
	- gobject-intospection folders: 1MB
	- legacy folders from the Adwaita theme: 7.6MB
	- ensurepip folders: 2MB
	- doc folders: 0.7MB
	Result:
	-	uncompressed set of install files down from 226MB to 202MB
		installer size is down 11MB (including the newly added windows-curses)
	- 	the profile log, filelist and Excel pivots used are uploaded to the 
		CleanUpInstallerByProfiling folder in the dowlnoad site.
5.	Replaced the remaining genric variable names with meaningful names.
6.	Decided to start writing this ChangeLog.txt :-D

02-Jun-2020 - deluge*.exe portability regression fix, build script fixes

1. 	update to libtorrent 1.2.7 (thanks for the report @highvoltage!)
2.	I got rid of the remnants of the C:\Program Files\Deluge2 folder, anyways,
	for a long time this installer too installs into C:\Program Files\Deluge.
3.	Updated deluge-build\deluge-stable.cmd and the deluge-dev.cmd to handle
	8.3 paths as well
4.	updated fixdeluged.py and fixdeluge-web.py did need updates too
5.	indicate the python, OpenSSL and GTK versions  used for the build in the
	installer name.

29-May-2020 - libtorrent and boost upgrades and optimization

1.	boost is updated to 1.73
2.	both 1.1.x and 1.2.x libtorrent builds are optimized for speed not space
3.	libtorrent and boost versions used for the build are indicated in the
	installer name.

29-May-2020 - first release in the new download location

1.	https://drive.google.com/drive/folders/1bCwij_GEy8nhqR6EynXYY_Yl7XuWYpVT
2.	update to libtorrent 1.2.6

TODO:
a.	Try to improve GTK3 build by telling it the exact Visual Studio version
	PATH is harcoded for 2019 anyhow :)
b.	Figure if building with LibTorrent 2.0 will have any chance of success.
c.	Build instrucitons
d.	upload the installer scripts to GitHub
e.	seems like some files for the 'en' and 'en-US' locale are not getting
	built properly, gotta check out and fix
f.	Remove the trailing, 4th level, seemingly useless .0 from
	LIBTORRENT_VERSION.
g.	Merge libtorrent build scripts (x3) and deluge-build scripts (x2)
h.	Bail out of the scipts on build error:
	|| echo ERROR Command returned error. && exit /b %errorlevel%
i.	Make sure the build scripts work in any folder, not only c:\deluge2
j. Refactor into "clean-code" .cmd files, use @echo instead of @rem :)