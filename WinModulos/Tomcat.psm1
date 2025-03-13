function tomcat(){
    Write-Host "Aqui va la instalacion y configuracion de Tomcat"
        # Página oficial de descargas de Apache Tomcat
    $tomcatPage = "https://tomcat.apache.org/download-90.cgi"  # Cambiar a la versión deseada (90, 10, 8)

    # Obtener el HTML de la página
    $html = Invoke-WebRequest -Uri $tomcatPage -UseBasicParsing

    # Buscar enlaces de descarga con regex
    $matche = $html.Links | Where-Object { $_.href -match "https://dlcdn.apache.org/tomcat/tomcat-\d+/v[\d.]+/bin/apache-tomcat-[\d.-]+-windows-x64.zip" }

    # Convertir los enlaces en una lista
    $downloadLinks = $matche.href | Sort-Object -Descending

    # Verificar si se encontraron enlaces
    if ($downloadLinks.Count -eq 0) {
        Write-Host "No se encontraron enlaces de descarga. Verifique la URL." -ForegroundColor Red
        exit
    }

    # Mostrar opciones al usuario
    Write-Host "Seleccione la versión de Apache Tomcat a descargar:"
    for ($i = 0; $i -lt $downloadLinks.Count; $i++) {
        Write-Host "$($i + 1)) $($downloadLinks[$i])"
    }

    # Solicitar la selección del usuario
    $choice = Read-Host "Ingrese el número de la versión que desea descargar"

    # Validar la entrada del usuario
    if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $downloadLinks.Count) {
        $selectedIndex = [int]$choice - 1
        $downloadUrl = $downloadLinks[$selectedIndex]
        $outputPath = "C:\Users\Administrador\Downloads\tomcat.zip"
        Write-Host "Descargando: $downloadUrl" -ForegroundColor Green
    } else {
        Write-Host "Opción no válida. Saliendo..." -ForegroundColor Red
        exit
    }

    # Descargar el archivo
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    Write-Host "Descarga completada: $outputPath" -ForegroundColor Cyan


    # Ruta de extracción
    $extractPath = "C:\Users\Administrador\Downloads\ApacheTomcat"

    # Crear directorio de extracción si no existe
    if (-not (Test-Path -Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath
    }

    # Extraer el archivo ZIP
    Expand-Archive -Path $outputPath -DestinationPath $extractPath
    Write-Host "Extracción completada en: $extractPath" -ForegroundColor Green

    # Definir variables
    $tomcatZip = "C:\Users\Administrador\Downloads\tomcat.zip"  # Ruta del archivo ZIP descargado
    $installPath = "C:\Tomcat"  # Carpeta de instalación
    $configFile = "$installPath\conf\server.xml"  # Archivo de configuración

    # Pedir al usuario el puerto deseado
    $port = Read-Host "Ingrese el puerto en el que desea ejecutar Tomcat (por defecto 8080)"
    
    # Verificar si ya está instalado
    if (-not (Test-Path $installPath)) {
        # Crear la carpeta de instalación
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null

        # Extraer el ZIP a la carpeta de instalación
        Write-Host "Extrayendo Tomcat..."
        Expand-Archive -Path $tomcatZip -DestinationPath $installPath -Force

        # Mover archivos si el ZIP crea una subcarpeta
        $tomcatFolder = Get-ChildItem -Path $installPath | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName
        if ($tomcatFolder -and ($tomcatFolder -ne $installPath)) {
            Move-Item -Path "$tomcatFolder\*" -Destination $installPath -Force
            Remove-Item -Path $tomcatFolder -Recurse -Force
        }
    }

    # Modificar server.xml para cambiar el puerto del conector HTTP
    if (Test-Path $configFile) {
        (Get-Content $configFile) -replace 'port="8080"', "port=`"$port`"" | Set-Content $configFile
        Write-Host "Configuración actualizada: Tomcat escuchará en el puerto $port" -ForegroundColor Cyan
    } else {
        Write-Host "No se encontró el archivo de configuración: $configFile" -ForegroundColor Red
        exit
    }

    # Configurar firewall para permitir tráfico en el puerto elegido
    Write-Host "Configurando Firewall..."
    New-NetFirewallRule -DisplayName "Tomcat HTTP" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction SilentlyContinue

    # Iniciar Tomcat
    Write-Host "Iniciando Tomcat ..."
    Start-Process -FilePath "$installPath\bin\startup.bat" -WorkingDirectory "$installPath\bin" -NoNewWindow

    Write-Host "Tomcat está ejecutándose....." -ForegroundColor Green

}