function tomcat(){
    Write-Host "Aqui va la instalacion y configuracion de Tomcat"
    
    Write-Host "Que version quiere usar?"
    Write-Host "[1].-LTS"
    Write-Host "[2].-Mainline"
    $opc = Read-Host "Elija una opcion:"
    switch($opc){
        1{
            $v = "11"
            $version = "11.0.5"
        }
        2{
            $v = "10"
            $version = "10.1.39"
        }
        default{
            Write-Host "Opción inválida, usando versión LTS por defecto"
            $v = "11"
            $version = "11.0.5"
        }
    }
    
    $serviceName = "Tomcat$v"
    
    # Eliminar servicio existente
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "Eliminando servicio anterior..."
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
        sc.exe delete $serviceName
        Start-Sleep -Seconds 5
    }
    
    # URL de descarga directa
    $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-$v/v$version/bin/apache-tomcat-$version-windows-x64.zip"
    $downloadPath = "$($env:USERPROFILE)\Downloads\apache-tomcat-$version.zip"
    
    Write-Host "Descargando Apache Tomcat $version..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    
    $extractPath = "C:\Apache"
    
    if (Test-Path "$extractPath\apache-tomcat-$version") {
        Remove-Item -Path "$extractPath\apache-tomcat-$version" -Recurse -Force
    }
    
    if (!(Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath -Force
    }
    
    Write-Host "Extrayendo archivos..."
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
    
    $tomcatPath = "$extractPath\apache-tomcat-$version"
    
    if (!(Test-Path $tomcatPath)) {
        Write-Host "Error: No se encontró la carpeta de Tomcat en $tomcatPath"
        return
    }
    
    # Modificar los archivos de configuración para eliminar opciones incompatibles
    Write-Host "Ajustando configuración de JVM para compatibilidad..."
    
    # Eliminar la opción --enable-native-access=ALL-UNNAMED del archivo catalina.bat
    $catalinaBatPath = "$tomcatPath\bin\catalina.bat"
    if (Test-Path $catalinaBatPath) {
        $catalinaBatContent = Get-Content $catalinaBatPath
        $catalinaBatContent = $catalinaBatContent -replace '--enable-native-access=ALL-UNNAMED', ''
        Set-Content -Path $catalinaBatPath -Value $catalinaBatContent
    }
    
    # Ajustar también setenv.bat si existe
    $setenvBatPath = "$tomcatPath\bin\setenv.bat"
    if (Test-Path $setenvBatPath) {
        $setenvContent = Get-Content $setenvBatPath
        $setenvContent = $setenvContent -replace '--enable-native-access=ALL-UNNAMED', ''
        Set-Content -Path $setenvBatPath -Value $setenvContent
    } else {
        # Crear un archivo setenv.bat que establezca las opciones de JVM correctas
        @"
@echo off
rem Configuración optimizada para Java 11
set "CATALINA_OPTS=%CATALINA_OPTS% -Xms512m -Xmx1024m"
"@ | Out-File -FilePath $setenvBatPath -Encoding ASCII
    }
    
    # Preguntar por el puerto
    $tomcatPort = Read-Host "Introduce el puerto que deseas utilizar para Apache Tomcat (por defecto: 8080)"
    if (-not $tomcatPort) {
        $tomcatPort = 8080
    }
    
    # Configurar el puerto
    $serverXmlPath = "$tomcatPath\conf\server.xml"
    if (Test-Path $serverXmlPath) {
        (Get-Content $serverXmlPath) -replace 'port="8080"', "port=`"$tomcatPort`"" | Set-Content $serverXmlPath
        Write-Host "Puerto configurado: $tomcatPort"
    } else {
        Write-Host "Error: No se encontró server.xml en $serverXmlPath"
        return
    }
    
    # Configurar regla de firewall
    Remove-NetFirewallRule -DisplayName "Tomcat $v" -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName "Tomcat $v" -Direction Inbound -Protocol TCP -LocalPort $tomcatPort -Action Allow
    
    # Establecer variables de entorno
    $env:CATALINA_HOME = $tomcatPath
    [Environment]::SetEnvironmentVariable("CATALINA_HOME", $tomcatPath, "Machine")
    
    # Modificar configuración del servicio
    Write-Host "Instalando servicio con configuración compatible..."
    Set-Location -Path "$tomcatPath\bin"
    
    # Instalar servicio
    & "$tomcatPath\bin\service.bat" install $serviceName
    
    # Verificar instalación 
    $newService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if (!$newService) {
        Write-Host "Error: No se pudo instalar el servicio $serviceName"
        return
    }
    
    # Iniciar servicio
    Write-Host "Iniciando el servicio Tomcat..."
    Start-Service -Name $serviceName -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    
    # Verificar estado
    $serviceStatus = Get-Service -Name $serviceName
    if ($serviceStatus.Status -eq "Running") {
        Write-Host "Apache Tomcat $version instalado y configurado correctamente en el puerto $tomcatPort."
        Write-Host "Puedes acceder a la aplicación en: http://localhost:$tomcatPort"
        
        # Abrir el navegador para mostrar Tomcat
        Start-Process "http://localhost:$tomcatPort"
    } else {
        Write-Host "Error: El servicio Tomcat no se pudo iniciar correctamente."
        Write-Host "Estado del servicio: $($serviceStatus.Status)"
        
        # Para depuración, mostrar los logs
        Write-Host "Revisando logs para diagnóstico..."
        if (Test-Path "$tomcatPath\logs\catalina.*.log") {
            Get-Content "$tomcatPath\logs\catalina.*.log" -Tail 20
        }
    }
}