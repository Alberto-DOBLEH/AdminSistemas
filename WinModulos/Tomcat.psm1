Import-Module "$PSScriptRoot/validadores.psm1"

function tomcat(){
    Write-Host "Aqui va la instalacion y configuracion de Tomcat"
    # 1. Descargar el HTML de la página de Apache Tomcat
    $url = "https://tomcat.apache.org/download-90.cgi"  # Puedes ajustar la versión si es necesario
    $html = Invoke-WebRequest -Uri $url -UseBasicParsing

    # 2. Extraer los enlaces de descarga de archivos ZIP usando expresiones regulares
    $match = [regex]::Matches($html.Content, 'href="(https://dlcdn.apache.org/tomcat/tomcat-9/v[0-9\.]+/bin/apache-tomcat-[0-9\.]+\.zip)"')

    # 3. Crear una lista de versiones disponibles
    $versions = $match | ForEach-Object { $_.Groups[1].Value }

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

        }
    }
    $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-$v/v$version/bin/apache-tomcat-$version-windows-x64.zip"

    $downloadPath = "$($env:USERPROFILE)\Downloads\apache-tomcat.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

    # 5. Preguntar al usuario qué puerto desea utilizar
    do{
        $port = Read-Host "Que puerto desea usar: "
        $valido = validar_puerto $port
        if($valido -eq $false){
            Write-Host "El puerto no es valido, intente de nuevo" -ForegroundColor Red
        }
    }while($valido -eq $false)

    # 6. Descomprimir el archivo ZIP y configurar el puerto
    $extractPath = "$($env:USERPROFILE)\Downloads\apache-tomcat"
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

    #Configurar el puerto
    $serverXmlPath = "$extractPath\apache-tomcat-$version\conf\server.xml"
    Write-Host $serverXmlPath
    if (Test-Path $serverXmlPath) {
        (Get-Content $serverXmlPath) -replace 'port="8080"', "port=`"$tomcatPort`"" | Set-Content $serverXmlPath
    } else {
        Write-Host "Error: No se encontró server.xml en $serverXmlPath"
    }

    New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort $tomcatPort -Action Allow   

    # 7. Iniciar Apache Tomcat
    #Start-Process "$extractPath\apache-tomcat-$version\bin\startup.bat"

    cd "$extractPath\apache-tomcat-$version\bin"

    .\service.bat install tomcat$v
    Start-Service -Name tomcat$v
    .\startup.bat
    Get-Service -Name tomcat$v

    Write-Host "Apache Tomcat $version instalado y configurado en el puerto $tomcatPort."
}
    