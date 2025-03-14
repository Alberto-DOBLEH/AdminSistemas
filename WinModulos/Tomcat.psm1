function tomcat(){
    Write-Host "Aqui va la instalacion y configuracion de Tomcat"
    # 1. Descargar el HTML de la página de Apache Tomcat
    $url = "https://tomcat.apache.org/download-90.cgi"  # Puedes ajustar la versión si es necesario
    $html = Invoke-WebRequest -Uri $url -UseBasicParsing

    # 2. Extraer los enlaces de descarga de archivos ZIP usando expresiones regulares
    $matches = [regex]::Matches($html.Content, 'href="(https://dlcdn.apache.org/tomcat/tomcat-9/v[0-9\.]+/bin/apache-tomcat-[0-9\.]+\.zip)"')

    # 3. Crear una lista de versiones disponibles
    $versions = $matches | ForEach-Object { $_.Groups[1].Value }

    # 4. Mostrar las versiones disponibles
    Write-Host "Versiones disponibles de Apache Tomcat:"
    for ($i = 0; $i -lt $versions.Count; $i++) {
        Write-Host "$($i + 1). $($versions[$i])"
    }

    $versionIndex = Read-Host "Elige el número de la versión que deseas descargar"
    $selectedVersion = $versions[$versionIndex - 1]

    # 4. Construir la URL de descarga y descargar el archivo ZIP
    $versionNumber = $selectedVersion.Substring($selectedVersion.LastIndexOf('-') + 1)
    $mainVersion = $selectedVersion.Substring(0, $selectedVersion.LastIndexOf('.'))
    $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-$(($mainVersion.Split('-'))[2])/v$versionNumber/bin/$selectedVersion.zip"

    $downloadPath = "$($env:USERPROFILE)\Downloads\apache-tomcat-$selectedVersion.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

    # 5. Preguntar al usuario qué puerto desea utilizar
    $tomcatPort = Read-Host "Introduce el puerto que deseas utilizar para Apache Tomcat (por defecto: 8080)"
    if (-not $tomcatPort) {
        $tomcatPort = 8080
    }

    # 6. Descomprimir el archivo ZIP y configurar el puerto
    $extractPath = "$($env:USERPROFILE)\Downloads\apache-tomcat-$selectedVersion"
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

    #Configurar el puerto
    $serverXmlPath = "$extractPath\conf\server.xml"
    (Get-Content $serverXmlPath) -replace 'port="8080"', "port=`"$tomcatPort`"" | Set-Content $serverXmlPath

    # 7. Iniciar Apache Tomcat
    Start-Process "$extractPath\bin\startup.bat"

    Write-Host "Apache Tomcat $selectedVersion instalado y configurado en el puerto $tomcatPort."
}
    