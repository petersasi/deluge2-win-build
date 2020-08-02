# replace PYTHONDIR with the root of your Python installation
with open(r'C:\Program Files\Deluge\Lib\site-packages\pip\_vendor\distlib\w64.exe', 'rb') as f:
    launcher = f.read()
with open(r'C:\Program Files\Deluge\deluge-web.exe', 'rb') as f:
    d = f.read()
with open(r'C:\Program Files\Deluge\deluge-web.exe', 'wb') as f:
    f.write(launcher)
    f.write(d[d.rindex(b'#!'):].replace(b'pythonw.exe', b'pythonw.exe'))
