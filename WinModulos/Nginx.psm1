function nginx(){
    Write-Host "Aqui va la instalacion y configuracion de Nginx"


    $nginxUrl = "https://nginx.org/en/download.html"
    $htmlContent = Invoke-WebRequest -Uri $nginxUrl -UseBasicParsing

    Write-Host "$htmlContent"
    # Extraer los enlaces de descarga usando regex
    $mainlineUrl = $htmlContent.Links | Where-Object { $_.href -match "nginx-\d+\.\d+\.\d+-mainline\.zip" } | Select-Object -ExpandProperty href
    $stableUrl = $htmlContent.Links | Where-Object { $_.href -match "nginx-\d+\.\d+\.\d+\.zip" -and $_.href -notmatch "mainline" } | Select-Object -ExpandProperty href

    write-Host "$mainlineUrl"
    write-Host "$stableUrl"

    # Verificar si se encontraron enlaces
    if (-not $mainlineUrl -or -not $stableUrl) {
        Write-Host "No se pudieron obtener los enlaces de descarga. Verifica la estructura de la página." -ForegroundColor Red
        exit
    }

    # URLs completas
    $baseDownloadUrl = "https://nginx.org"
    $mainlineUrl = $baseDownloadUrl + $mainlineUrl
    $stableUrl = $baseDownloadUrl + $stableUrl

    # Mostrar opciones al usuario
    Write-Host "Seleccione la versión de Nginx a descargar:"
    Write-Host "1. Mainline Version: $mainlineUrl"
    Write-Host "2. Stable Version: $stableUrl"

    $choice = Read-Host "Ingrese el número de la versión que desea descargar"

    # Determinar qué archivo descargar
    if ($choice -eq "1") {
        $downloadUrl = $mainlineUrl
        $fileName = "nginx.zip"
    } elseif ($choice -eq "2") {
        $downloadUrl = $stableUrl
        $fileName = "nginx.zip"
    } else {
        Write-Host "Opción no válida. Saliendo..." -ForegroundColor Red
        exit
    }

    # Ruta de guardado
    $outputPath = "C:\Users\Administrator\Downloads\$fileName"

    # Descargar el archivo
    Write-Host "Descargando $fileName..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    Write-Host "Descarga completada" -ForegroundColor Green

    # Definir variables
    $nginxZip = "C:\Users\Administrator\Downloads\nginx.zip"  # Ruta del archivo ZIP descargado
    $installPath = "C:\Nginx"  # Carpeta de instalación
    $configFile = "$installPath\conf\nginx.conf"  # Ruta del archivo de configuración

    # Pedir al usuario que ingrese el puerto deseado
    $port = Read-Host "Ingrese el puerto en el que desea ejecutar Nginx (por defecto 80)"

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

    # Iniciar Nginx
    Write-Host "Iniciando Nginx en el puerto $port..."
    Start-Process -FilePath "$installPath\nginx.exe" -WorkingDirectory $installPath -NoNewWindow

    Write-Host "Nginx está ejecutándose.." -ForegroundColor Green

}