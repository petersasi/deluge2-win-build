#!/usr/bin/env python
import os
import sys

filedir_list = []
for root, dirnames, filenames in os.walk(sys.argv[1]):
    dirnames.sort()
    filenames.sort()
    filedir_list.append((root[len(sys.argv[1]) :], filenames))

with open('C:\\deluge2\\nsis\\packaging\\win32\\install_files.nsh', 'w') as f:
    f.write('; Files to install\n')
    for dirname, files in filedir_list:
        if not dirname:
            dirname = os.sep
        f.write('\nSetOutPath "$INSTDIR%s"\n' % dirname)
        for filename in files:
            f.write('File "${BBFREEZE_DIR}%s"\n' % os.path.join(dirname, filename))

with open('C:\\deluge2\\nsis\\packaging\\win32\\uninstall_files.nsh', 'w') as f:
    f.write('; Files to uninstall\n')
    for dirname, files in reversed(filedir_list):
        f.write('\n')
        if not dirname:
            dirname = os.sep
        for filename in files:
            f.write('Delete "$INSTDIR%s"\n' % os.path.join(dirname, filename))
        f.write('RMDir "$INSTDIR%s"\n' % dirname)
