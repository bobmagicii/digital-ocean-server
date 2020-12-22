@echo off

:: generate some sane variables.

set RemoteHost=%1
set KeyFile=%UserProfile%\.ssh\id_rsa
set KeyFilePPK=%UserProfile%\.ssh\id_rsa.ppk

:: upload my files to the server.

echo Uploading Files...
scp -q -o "StrictHostKeyChecking no" -i %KeyFile% upload/setup.sh root@%RemoteHost%:.
scp -r -q -o "StrictHostKeyChecking no" -i %KeyFile% upload/setup root@%RemoteHost%:.

:: pop us a putty

echo Opening Putty...
start putty root@%RemoteHost% -i %KeyFilePPK%

:: final parting words.

echo Run 'sh setup.sh' on the remote host to get started.
