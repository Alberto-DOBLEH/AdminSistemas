Import-Module "$PSScriptRoot/validadores.psm1"

function nginx(){
    Write-Host "Aqui va la instalacion y configuracion de Nginx"


        # URL de la página de descargas de Nginx
    $nginxPageUrl = "https://nginx.org/en/download.html"

    # Descargar el HTML de la página
    Write-Host "Descargando la página de Nginx..." -ForegroundColor Cyan
    $html = Invoke-WebRequest -Uri $nginxPageUrl -UseBasicParsing

    # Expresión regular corregida para capturar los enlaces de las versiones Mainline y Stable
    $mainlineRegex = '<a href="(/download/nginx-[0-9.]+.zip)">nginx/Windows-[0-9.]+</a>'
    $stableRegex = '<a href="(/download/nginx-[0-9.]+.zip)">nginx/Windows-[0-9.]+</a>'

    # Extraer la URL de la versión Mainline
    $mainlineMatch = [regex]::Match($html.Content, $mainlineRegex)
    if ($mainlineMatch.Success) {
        $mainlineUrl = "https://nginx.org" + $mainlineMatch.Groups[1].Value
        Write-Host "Mainline version encontrada: $mainlineUrl" -ForegroundColor Green
    } else {
        Write-Host "No se encontró la Mainline version." -ForegroundColor Red
    }

    # Extraer la URL de la versión Stable
    $stableMatch = [regex]::Match($html.Content, $stableRegex, [System.Text.RegularExpressions.RegexOptions]::RightToLeft)
    if ($stableMatch.Success) {
        $stableUrl = "https://nginx.org" + $stableMatch.Groups[1].Value
        Write-Host "Stable version encontrada: $stableUrl" -ForegroundColor Green
    } else {
        Write-Host "No se encontró la Stable version." -ForegroundColor Red
    }

    # Permitir al usuario elegir qué versión descargar
    $choice = Read-Host "Seleccione la versión de Nginx a descargar (1 para Mainline, 2 para Stable)"
    if ($choice -eq "1" -and $mainlineUrl) {
        $downloadUrl = $mainlineUrl
    } elseif ($choice -eq "2" -and $stableUrl) {
        $downloadUrl = $stableUrl
    } else {
        Write-Host "Selección inválida o versión no encontrada." -ForegroundColor Red
        exit
    }

    # Definir ruta de descarga
    $outputPath = "C:\Users\Administrador\Downloads\nginx.zip"

    # Descargar el archivo seleccionado
    Write-Host "Descargando Nginx desde $downloadUrl..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

    Write-Host "Descarga completada: $outputPath" -ForegroundColor Green

    # Definir variables
    $nginxZip = "C:\Users\Administrador\Downloads\nginx.zip"  # Ruta del archivo ZIP descargado
    $installPath = "C:\Nginx"  # Carpeta de instalación
    $configFile = "$installPath\conf\nginx.conf"  # Ruta del archivo de configuración

    # Pedir al usuario que ingrese el puerto deseado
    do{
        $port = Read-Host "Que puerto desea usar: "
        $valido = validar_puerto $port
        if($valido -eq $false){
            Write-Host "El puerto no es valido, intente de nuevo" -ForegroundColor Red
        }
    }while($valido -eq $false)

    # Verificar si ya está instalado
    if (-not (Test-Path $installPath)) {
        # Crear la carpeta de instalación
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null

        # Extraer el ZIP a la carpeta de instalación
        Write-Host "Extrayendo Nginx..."
        Expand-Archive -Path $nginxZip -DestinationPath $installPath -Force

        # Mover archivos al directorio correcto (si el ZIP crea una subcarpeta)
        $nginxFolder = Get-ChildItem -Path $installPath | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName
        if ($nginxFolder -and ($nginxFolder -ne $installPath)) {
            Move-Item -Path "$nginxFolder\*" -Destination $installPath -Force
            Remove-Item -Path $nginxFolder -Recurse -Force
        }
    }

    # Modificar el archivo de configuración de Nginx para usar el puerto ingresado
    if (Test-Path $configFile) {
        (Get-Content $configFile) -replace "listen\s+\d+;", "listen $port;" | Set-Content $configFile
        Write-Host "Configuración actualizada: Nginx escuchará en el puerto $port" -ForegroundColor Cyan
    } else {
        Write-Host "No se encontró el archivo de configuración: $configFile" -ForegroundColor Red
        exit
    }

    # Configurar firewall para permitir tráfico en el puerto elegido
    Write-Host "Configurando Firewall..."
    New-NetFirewallRule -DisplayName "Nginx" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction SilentlyContinue

    cd $installPath
    # Iniciar Nginx
    Write-Host "Iniciando Nginx en el puerto $port..."
    Start-Process "$installPath\nginx.exe"

    Write-Host "Nginx está ejecutándose.." -ForegroundColor Green

    cd C:\Users\Administrador

}