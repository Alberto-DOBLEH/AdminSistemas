function tomcat(){
    Write-Host "Aqui va la instalacion y configuracion de Tomcat"
    # URL de la página de descargas de Apache Tomcat
    $tomcatUrl = "https://tomcat.apache.org/download-90.cgi"

    # Descargar el HTML de la página
    $htmlContent = Invoke-WebRequest -Uri $tomcatUrl -UseBasicParsing

    # Extraer los enlaces de descarga para las versiones de Tomcat
    $downloadLinks = $htmlContent.Links | Where-Object { $_.href -match "apache-tomcat-\d+\.\d+\.\d+-windows-x64\.zip" } | Select-Object -ExpandProperty href

    # Verificar si se encontraron enlaces
    if (-not $downloadLinks) {
        Write-Host "No se pudieron obtener los enlaces de descarga. Verifica la estructura de la página." -ForegroundColor Red
        exit
    }

    # Mostrar opciones al usuario
    Write-Host "Seleccione la versión de Apache Tomcat a descargar:"
    $downloadLinks | ForEach-Object { Write-Host "$($_.Split('/')[-1])" }

    $choice = Read-Host "Ingrese el nombre exacto del archivo que desea descargar"

    # Validar la elección del usuario
    if ($downloadLinks -contains $choice) {
        $downloadUrl = "https://tomcat.apache.org" + $choice
        $fileName = "tomcat.zip"
    } else {
        Write-Host "Opción no válida. Saliendo..." -ForegroundColor Red
        exit
    }

    # Ruta de guardado
    $outputPath ="C:\Users\Administrator\Downloads\$fileName"

    # Descargar el archivo
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    Write-Host "Descarga completada" -ForegroundColor Green

    # Ruta de extracción
    $extractPath = "C:\Users\Administrator\Downloads\ApacheTomcat"

    # Crear directorio de extracción si no existe
    if (-not (Test-Path -Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath
    }

    # Extraer el archivo ZIP
    Expand-Archive -Path $outputPath -DestinationPath $extractPath
    Write-Host "Extracción completada en: $extractPath" -ForegroundColor Green

    # Definir variables
    $tomcatZip = "C:\Users\Administrator\Downloads\$fileName"  # Ruta del archivo ZIP descargado
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