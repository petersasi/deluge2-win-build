# deluge2-win-build
A set of scripts to prepare prerequisites for and build Deluge Torrent 2.0.x on Windows 10

## IMPORTANT!
The current release folder for these builds (the "Deluge2 Unofficial Installer for Windows" Google Drive Folder) contains several older builds with older build logic and library versions just in case you would find it useful to go back.
PLEASE switch to List View (top right corner icon) to see the file dates and download the _latest_ version **unless you know what you are doing!**
Your maintainer mostly uses the latest, non-portable dev version with thin client and daemon mode on Windows 10 with the Adwaita-dark theme, so consider that combination the best tested.

## BUILDING
To build Deluge2 for windows use the scripts in the below order.

### Install the prerequisites
The main goal is to have as little of these as possible not to pollute the building computer. At the same time if something really is needed, I would rather use the original installers (e.g. 7zip vs. 7zip.NET - ended up using the one in MSYS2 - nota bene: feels sluggish compared to the native Win64 version which is also 3 major versions newer).
```install_components.cmd```
1.	7zip
2.	MSYS2
3.	NullSoft Scriptable Intstaller System
4.	NSprocess plugin for NSIS for process control
5.	StrContains plugin for NSIS
6.	Microsoft Visual Studio 2019
7.	Latest OpenSSL release using ```openssl-build\openssl.cmd```
8.	Create links for the shared code in the lib folder using ```createlinks.cmd``` (called by ```install_components.cmd```)

### Build
1.	GTK-3 using wingtk/gvsbuild ```gvsbuild-build\gvsbuild.cmd```
2.	Libtorrent, 3 flavours, including and using Boost and it's B2 build system and the latest Python version ```libtorrent-build\{lt-RC_1_2.cmd,lt-RC_1_1.cmd,lt-1.2.3.cmd}```
3.	Deluge: the latest release version and the latest dev version. Including and using the latest Python version. ```deluge-build\{deluge-dev.cmd,deluge-stable.cmd}```
4.	Installers for the above ```installer-build\installer-build.cmd all|dev|stable```

The current set of scripts is a work in progress lacking several flavours of cleanup, see TODO at the end. Priority is given to features so the cleanup is not yet finished, patches / PRs
are welcome! ;)

## CHANGE LOG

### 21-Feb-2021 - All new and bugfixed component versions, build system rewamp

1.	Upgraded Deluge Torrent to dev50 version: cas has reactivated and merged for the first tie since 30-Apr-2020. New fixes:
	(a)	[#3441|GTKUI] Add a torrentdetails tabs position menu
	(b) Hide pygame community banner in console
	Notifications plugin uses pygame for sound notifications however pygame show a console message "Hello from the pygame community." whenever starting deluge from console.
	(c) [GTKUI] Fix torrentdetails tab bar position not saving
	The GTKUI tests were failing and the saved config for the tab bar position was not being restored. Fixed by moving the setting of notebook.tabs_pos to TorrentDetail init. Replaced more deprecated methods that were showing up in tests.
	(d) [#3440] Fix httpdownloader reencoding torrent file downloads
	Torrent downloads from rutracker responds with the header:
	Content-Type: application/x-bittorrent; charset=Windows-1251
	The problem is that httpdownloader was using the charset to re-encode the downloaded file, corrupting the binary torrent file download. Fixed by only re-encoding text content types, since it is very rare that non-text content types would actually have a non-utf8 codeset and if there is a requirement we would need to determine it on a type by type basis.
	(e) [#3337|Core] Fix lt listen_interfaces not comma-separated
	A typo meant that the interfaces supplied to libtorrent were not
comma-separated.
	(f) [#3325|Core] Fix unable to remove magnet with delete_copies enabled
	Users were encountering the following error while attempting to delete magnet torrents and had the config 'Delete copy of torrent file' enabled. This was due to removing a magnet before the metadata was downloaded and the torrent.filename was still set to None so raises exceptions when string operations are performed with it. Fixed by both setting a default empty string for self.filename and only deleting the torrent file copy if filename is set.
	(g) [WebUI] Add country flag alt/title for accessibility
	This allows viewing the country in textual form by hovering the flag
image and displays it if the image couldn't be loaded.
	(h) [Tests] Fix console tests sometimes failing due to hard coded port
	(i) [WebUI] Fix tracker icon download error
	Encoutering an error when webui attempts to download tracker icon: Fixed by ensuring the request.tracker_name is decoded from bytes before looking up the icon name.
	(j) [Console] Fix setting 'Skip' priority on console 
	Selecting priorities 'Low' and 'Skip' on console will both set the
actual priority to 'Low'. Fixed typo.
	(k) [#3439] Execute plugin fails to run on Windows 
	Fixed TypeError: a bytes-like object is required, not 'str'
	(l) [Lint] Update pre-commit hook and isort versions
	 * Fixed black hook requiring Py3.6 to installed locally. Will now assume Py3.6+ in installed.
	* Added isort traceback in pre-commit flake8 hook fails
	* Updated versions of Black, Prettier and isort
	* Keep Flake8 at 3.7.9 due to E402 issue: https://gitlab.com/pycqa/flake8/-/issues/638
	* New pyproject config for isort v5 with fixes for Python 2 imports.
	* Fixed travis config to run Python 3.6 for lint run. Replaced the virtualenv with_system_site_packages config with Travis specific Python config value so lint run doesn't attempt to append with_system_site_packages to Python 3.6 command.
2. Ugraded Python version upgraded to 3.9.2
	(a) had to find and download a precompiled Twisted cp39, does not build and install using pip on my box
	(b) switched to using pycairo from pip, works for me
	(c) excluded more unnecessary components from the installation (TCL/TK, docs)
	(d) while having some patching trouble I ended up removing a pycairo and a PyGobject __init__.py patched disabling PATH lookup and instead corrected our path.pth (in 4 places)
3. Upgraded LibTorrent to 1.2.13
	libtorrent has replaced it's setup.py to had to come up with a new way to build with OpenSSL
	Asked for a backport from LibTorrent 2.0 to 1.2 by the nice LibTorrent devs now we can build again
	as a side effect they also uncovered an easy way to use LTO/Whole Program Optimization
	Includes potential performance and bugfixes too!
4. Build system major rewamp:
	(a) caught many typos and bugs in the rewamp
	(b) fixed removing unused files in folders with changing names (due to version numbers) - had to implement a batch-grep bash script to speed it up, also added dry-run mode
	(c) xternalized common functions to a lib folder, use common resources, e.g. python installer
	(d) as a result moved pip to pythonInit, and all modules + the deluge buils itself are built in a single pip command
	(e) easier to review color coded messages
	(f) scripts now bail out on error, if it completes it's reasonably sure build is successful
	(g) Tried implementing the Windows CMD scripts in "clean code" the messages along the build explaining the script instead of code comments
	(h) removed long unused parts
	(i) updated copyright messages, fixed MHertz's name, sorry!
	(k) Updated MS Visual Studio Build Tools 2019 to 16.8.4
	(l) Updated build MSYS2
5. Upgraded OpenSSL version to 1.1.1j
6. Updated to the rebuilt GTK version 3.24.25
7. Found out my GeoIP download source is no longer working, picked up the new one from MHertz's repo, thanks! :)
8. Also updated path.pth from MHertz's repo, then fixed it not to use relative paths in PATH :)

### 18-Sep-2020 - fix 3rd party plugins, build maintainability and readability

1.	Upgraded OpenSSL to 1.1.1h, saved OpenSSL changelog to the download forder for your convenience.
2.	Changed file removal to MSYS2 find command to flexibly handle folder names changing with library versions (e.g. also changing number of version levels and digits for the same package)

### 18-Sep-2020 - fix 3rd party plugins, build maintainability and readability

1.	Updated MS Visual Studio used for the build from 16.6.0 to 16.7.3 and rebuilt GTK, Boost-LibTorrent
2.	Removed some items from the GTK build also making the installer slightly smaller

### 17-Sep-2020 - fix 3rd party plugins, build maintainability and readability

1.	Upgraded built in GTK version to 3.24.23
2.	Upgraded built in LibTorrent version to 1.2.10
3.	Upgraded Boost used to build LibTorrent to 1.74.0
4.	Reworked gvsbuild.cmd to
	(a)	use the common PATH init-restore
	(b)	use the common file and folder removal logic
	(c)	use common initPython
	(d)	use common highlight printing.
5.	Externalize common code of
	(a)	Python download, install, initialization and removal to lib.
	(b)	Removal of a list of files and folders (fixed lists, should not have trailing spaces)
6.	Made initpath.cmd smarter:
	(a)	ability to add build specific dirs as well on a single command line
	(b)	not overwrite already saved PATH
7.	restorepath.cmd to check if there is a saved path.
8.	Shortened version numbers in file name even further.

### 13-Aug-2020 - bug fix and build fix to make these noticed

1.	Fixed log.py patching from last time #2.
2.	Modified deluge-build scripts to bail out and stop the batch execution on all patching and many other build erros so that these can no longer go unnoticed.

### 10-Aug-2020 - fix 3rd party plugins, build maintainability and readability

1.	Added YaRSS2 plugin to the installer and re-added the files that were missing for those.
2.	Patched out the complex code in log.py trying (and failing on Windows) to monkey-patch the calling module's `log` attribute, and just leave the original warning there to help the users of 3rd party plugins using deprecated log interfaces, courtesy of MHertz.
3.	Create a single installer build script with paramteres.
4.	Added Build Menu cmd file from MHertz.
5.	Added a lib folder for common build code an createlinks.cmd to create a symlink to it into each build folder
6.	Made sure the curl we use is from the MSYS2 we installed, not the windows one.
7. 	Reverted installing 7zip for windows and instead added it to the packages installed in MSYS2.
8.	Start using color to make build messages pop more out of the build output
9.	Unified Copyright notices in all CMD files

### 3-Aug-2020 - fix missing files for Test connection

1.	The extensive file clean up removed a bit too many files, fixed for test connection problem reported.
2.	Shorten installer filename another 7 characters.

### 2-Aug-2020 - publish build scripts and guide at on github

1.	Find the scripts and guide on [github](https://github.com/petersasi/deluge2-win-build)
2.	Removed the patches from the relese download site as now they are available on github.

### 1-Aug-2020 - portable install fix and Latest GTK3

1.	Fixed the portability move of the profile folder into the install dir.
2.	Built GTK 3.24.21 into the new install.

### 31-Jul-2020 - 34% smaller, Win integration, portability&build fixes, new vers

1.	One third smaller installer and Installed Deluge folder through profiling of deluge, deluged, deluge-web and deluge-console using Process Monitor and removing the files not used according to the profiling.
	_EXCEPTIONS_ are .exe files and folders that have 'locale' or 'hazmat' in their name.
	**PLEASE test and let me know if I have removed too much!!!**
2.	Better Windows integration through alternative loaders, courtesy of @MHertz:
	- Now can pin deluge on taskbar
	- shows only one deluge / deluged / deluge-web process, python[w].exe is embedded.
	- loader has Deluge icons
3.	Updated LibTorrent to 1.2.8 released 30-Jul-2020.
4.	Updated to Python to version 3.8.5 released on 20-Jul-2020.
5.	Portable install fix to put the deluge profile folder as well in the data subfolder of the deluge install folder in case of portable installations, courtesy of @MHertz.
6.	Updated te GeoIP database and added the automated GeoIP database update to the build system, courtesy of @MHertz.
7.	Fixed the torrentmanager.py patch from @djlegolas for the stable deluge-build.
8.	Install wheel using pip during deluge-build to avoid build warnings.
9.	Removed LIBTORRENT_REVISION from the file names as it seems useless. Other installer name fixes.
10.	Stopped copying the vcvarsall.bat around to make the LibTorrent build happy using proper build commands.
11.	Added up to date ```LibTorrent-ChangeLog.txt```, ```GTK-3.24-ChangeLog.txt``` and ```Python-ChangeLog.txt``` to the "Deluge2 Unofficial Installer for Windows" folder to make it easy for you to check what fixes are included in the new version.
12.	Moved earlier releases to an Archive folder.

### 21-Jun-2020 - make deluge-console.exe work for non-interactive commands

1.	Created a patch to swallow the AttributeError because of not having the signal SIGWINCH on Windows in Python windows-curses. Now you can run:
	```deluge-console.exe status```
	```deluge-console.exe info``` etc.
	[A ticket](https://dev.deluge-torrent.org/ticket/3409 ) is submitted with a patch for this.
2.	Created a patch to replace the "Deluge-console does not run in interactive mode on Windows." message and exiting. Instead we just log a debug message and carry on. Now the interactive UI starts but does not accept any input. The log is full of a twister error for win32select. I am stuck here, will have to ask for the help of the devs.
	[A ticket](https://dev.deluge-torrent.org/ticket/3410) is submitted with a patch for this.
3.	Published patches in a folder on the download site.

### 20-Jun-2020	- revive deluge-console, updated Deluge patch, reduced build size, enhanced build scripts, ChangeLog

1.	The default ncurses in Python is not supported (and does not work) on Windows. Including [windows-curses 2.1.0](https://pypi.org/project/windows-curses/) in the hope to revive that - it should have a hack to make it work (thanks for the report @mystikfox!)
2. PR by @djlegolas regarding ignoring untrue libtorrent 1.2.x tracker errors from UIs was updated - replaced the old URL in the ```deluge-build\deluge-{dev,stable}.cmd``` scripts.
3.	Refactored the folder cleanup logic in ```deluge-build\deluge-{dev,stable}.cmd``` scripts to use a list from a text file instead of the previously 12 later much more lines of ```rd /s /q``` (```"%programfiles%\deluge\"``` added to all).
4.	First slimming of the installer by profiling to find files never touched, removed - this round only strips away complete folders unused:
	- test / tests / unittest folders: 18.2MB
	- demos folders: 0.9MB 
	- gobject-intospection folders: 1MB
	- legacy folders from the Adwaita theme: 7.6MB
	- ensurepip folders: 2MB
	- doc folders: 0.7MB
	Result:
	-	uncompressed set of install files down from 226MB to 202MB installer size is down 11MB (including the newly added ```windows-curses```)
	- 	the profile log, filelist and Excel pivots used are uploaded to the 
		CleanUpInstallerByProfiling folder in the dowlnoad site.
5.	Replaced the remaining genric variable names with meaningful names.
6.	Decided to start writing this ChangeLog.txt :-D

### 02-Jun-2020 - deluge*.exe portability regression fix, build script fixes

1. 	update to libtorrent 1.2.7 (thanks for the report @highvoltage!)
2.	I got rid of the remnants of the C:\Program Files\Deluge2 folder, anyways, for a long time this installer too installs into ```C:\Program Files\Deluge```.
3.	Updated ```deluge-build\deluge-stable.cmd``` and the ```deluge-dev.cmd``` to handle	8.3 paths as well.
4.	updated fixdeluged.py and fixdeluge-web.py did need updates too
5.	indicate the python, OpenSSL and GTK versions  used for the build in the installer name.

### 29-May-2020 - libtorrent and boost upgrades and optimization

1.	boost is updated to 1.73
2.	both 1.1.x and 1.2.x libtorrent builds are optimized for speed not space.
3.	libtorrent and boost versions used for the build are indicated in the installer name.

### 29-May-2020 - first release in the new download location

1.	[New release folder](https://drive.google.com/drive/folders/1bCwij_GEy8nhqR6EynXYY_Yl7XuWYpVT)
2.	update to libtorrent 1.2.6

## TODO
-	seems like some files for the 'en' and 'en-US' locale are not getting built properly, gotta check out and fix
-	Remove the trailing, 4th level, seemingly useless .0 from ```LIBTORRENT_VERSION```
-	Merge libtorrent build scripts (x3) and deluge-build scripts (x2)
-	Bail out of the scipts on build error: ```|| echo ERROR Command returned error. && exit /b %errorlevel%```
-	Make sure the build scripts work in any folder, not only ```c:\deluge2```
-	Refactor the .cmd files into "clean-code": use ```@echo``` instead of ```@rem``` :)
-	Added the other requested 3rd party plugin, autoremoveplus patched with replacing the deprecated logging by MHertz (the tote94 fork as it has GTK interface too and AFAIK cannot include two forks of the plugin with the same name)
-	Delete unnecessary files independent of the version number in he directory name including them
-	Scrape latest Boost release version instead hard coding into the script
-	Pick up PRs from deluge-torrent github for e.g. interface binding enhancements
-	Use user mode Python instead if installing needing Admin credentials
-	Fix PyGobject name problem
-	Compile an LTO / WPO optimized OpenSSL ourselves (form MHertz)

