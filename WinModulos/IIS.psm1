function IIS(){
    #Obtenecion del modulo de IIS
    Get-WindowsFeature -Name *IIS*

    #Instalacion del Web Server que utilizaremos en IIS
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools

    #Creacion de las carpeta de contencion del sitio
    $httpPath = "C:\HTTP"
    $pagePath = "$httpPath\Pagina"
    New-Item -ItemType Directory -Name "HTTP" -Path $httpPath
    New-Item -ItemType Directory -Name "Pagina" -Path $pagePath

    #Creacion del archivo Index de la pagina 
    New-Item -ItemType File -Name "index.html" -Path "$pagePath\"

    $port = Read-Host "Que puerto desea usar? "

    #Ceacion del IIS Site
    New-IISSite -Name "Pagina" -PhysicalPath "$pagePath\" -BindingInformation "*:$($port):"

    #Regla de Firewall
    New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow


    #Agregar el formato de HTML dentro del archivo
    # Definir la ruta donde se guardará el archivo
    $ruta = "$pagePath\index.html"

    # Definir el contenido HTML como una cadena
    $contenidoHTML = @"
<!DOCTYPE html>
<html>

    <head>
        <title>Prueba de IIS creado con PowerShell</title>
    </head>

    <body>
        <h1>Prueba de IIS creado con PowerShell</h1>
        <p>Esto lo hacemos para las pruebas de <b>Jotelulu</b></p>
        <p>Creando una webpage de IIS mediante <b>PowerShell</b></p>
    </body>

</html>
"@

    # Escribir el contenido en el archivo (crea o sobrescribe)
    Set-Content -Path $ruta -Value $contenidoHTML -Encoding UTF8

    #Iniciar el servidor
    Start-IISSite -Name "Pagina"

    #Verificar que este corriendo la pagina
    Get-IISSite -Name "Pagina"
}