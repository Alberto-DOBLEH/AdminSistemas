function install_squirrel{
    
    #Seccion de instalacion de SquirrelMail
    # Ruta de instalación de Apache (htdocs)
    $htdocsPath = "C:\xampp\htdocs\squirrelmail"

    # Crear carpeta
    New-Item -Path $htdocsPath -ItemType Directory -Force | Out-Null

    # Descargar desde GitHub
    $zipUrl = "https://github.com/emersion/squirrelmail/archive/refs/heads/master.zip"
    $zipPath = "C:\Installers\squirrelmail.zip"

    
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

    # Descomprimir el archivo ZIP
    Expand-Archive -Path $zipPath -DestinationPath "C:\Installers" -Force

    # Copiar contenido a htdocs
    $extractedFolder = "C:\Installers\squirrelmail-master"
    Copy-Item -Path "$extractedFolder\*" -Destination $htdocsPath -Recurse -Force

    # Crear carpeta de configuración si no existe
    $configFolder = "$htdocsPath\config"
    New-Item -Path $configFolder -ItemType Directory -Force | Out-Null

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