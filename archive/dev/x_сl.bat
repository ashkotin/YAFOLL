@echo off
set p1=%PATH%
rem set pg=C:\Program Files\PostgreSQL\9.2
rem это путь из их "€рзыка"-64
set vcp=C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\MSBuild\12.0\bin;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\BIN\x86_amd64;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\VCPackages;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Team Tools\Performance Tools;C:\Program Files (x86)\Windows Kits\8.1\bin\x86;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\x64\;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
set PATH=%vcp%;C:\Program Files\PostgreSQL\9.2\lib
cl C_prog.c /IC:\Program Files\PostgreSQL\9.2\include 
rem SA_FOLsn.c /IC:\Program Files\PostgreSQL\9.2\include 
rem set PATH=%p1%;C:\Program Files\PostgreSQL\9.2\lib
rem SA_FOLsn.exe <test_sigs_terms.fol >SA.out.html
rem notepad SA.out.html
pause