
function install_mercury{

    # Instalacion de mercury
    $downloadPath = "https://download-us.pmail.com/m32-480.exe"
    $downloadedPath = "$env:HOMEPATH\Downloads\mercury.exe"

    Invoke-WebRequest -Uri $downloadPath -Outfile $downloadedPath -UseBasicParsing -ErrorAction Stop
    cd $env:HOMEPATH\Downloads
    Start-Process .\mercury.exe

    Start-Process -FilePath "C:\MERCURY\mercury.exe" -ArgumentList "/install" -Wait

    #Seccion de instalacion de XAMPP
    New-Item -Path "C:\Installers" -ItemType Directory -Force | Out-Null

    # Descargar XAMPP (asegurate de tener curl en PowerShell v5+)
    $xamppUrl = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/5.6.40/xampp-windows-x64-5.6.40-1-VC11-installer.exe/download"
    $outputPath = "C:\Installers\xampp-installer.exe"

    Invoke-WebRequest -Uri $xamppUrl -OutFile $outputPath

    # Ejecutar el instalador de XAMPP
    Start-Process -FilePath $outputPath


    #Seccion de instalacion de SquirrelMail
    # Ruta de instalación de Apache (htdocs)
    $htdocsPath = "C:\xampp\htdocs\squirrelmail"

    # Crear carpeta
    New-Item -Path $htdocsPath -ItemType Directory -Force | Out-Null

    # Descargar desde GitHub
    $zipUrl = "https://www.squirrelmail.org/countdl.php?fileurl=http%3A%2F%2Fprdownloads.sourceforge.net%2Fsquirrelmail%2Fsquirrelmail-webmail-1.4.22.zip"
    $zipPath = "C:\Installers\squirrelmail.zip"

    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

    # Extraer ZIP
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, "C:\Installers")

    # Copiar contenido a htdocs
    Copy-Item -Path "C:\Installers\squirrelmail-master\*" -Destination $htdocsPath -Recurse -Force

    #Configuracion de SquirrelMail
    $configPath = "$htdocsPath\config\config.php"

# Crear configuración básica
$configContent = @"
<?php
\$domain           = 'correo.local';             // Tu dominio (o IP interna)
\$imapServerAddress = '127.0.0.1';               // IP del servidor Mercury (IMAP)
\$imapPort         = 143;
\$smtpServerAddress = '127.0.0.1';               // IP Mercury SMTP
\$smtpPort         = 25;
\$imap_server_type = 'other';
\$useSendmail      = false;
\$smtp_auth_mech   = 'login';
\$smtpUserName     = '';
\$smtpPassword     = '';
?>
"@

$configContent | Set-Content -Path $configPath -Encoding UTF8

}

