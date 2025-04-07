
$downloadPath = "https://download-us.pmail.com/m32-480.exe"
$downloadedPath = "$env:HOMEPATH\Downloads\mercury.exe"

Invoke_WebRequest -Uri $downloadPath -Outfile $downloadedPath -UseBasicParsing -ErrorAction Stop
cd $env:HOMEPATH\Downloads
Start-Process .\mercury.exe


