function install_squirrel{
    
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