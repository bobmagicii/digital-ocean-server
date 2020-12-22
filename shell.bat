@echo off

set RemoteHost=%1
set KeyFilePPK=%UserProfile%\.ssh\id_rsa.ppk

echo Opening PuTTY.
start putty bob@%RemoteHost% -i %KeyFilePPK%
