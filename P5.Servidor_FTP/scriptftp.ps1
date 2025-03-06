#Importacion de modulos
Import-Module ../WinModulos/validadores.psm1
Import-Module ../WinModulos/usuarios.psm1

#Verificacion Inicial del servicio FTP 
# $serviceName = "FTPSVC"
# $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

# if ($null -ne $service) {
#    Write-Host "El servicio FTP ya está instalado."
# } else {
    #Write-Host "El servicio FTP no está instalado. Procediendo a la instalación..."
   
    #Instalacion de los servcios para el servidor FTP
    Write-Host "Instalando servicios necesarios para el servidor FTP..." -ForegroundColor Yellow
    Install-WindowsFeature Web-FTP-Server -IncludeAllSubFeature -IncludeManagementTools
    Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools
    Install-WindowsFeature Web-Basic-Auth
    Install-WindowsFeature Web-Mgmt-Service -IncludeManagementTools
    Import-Module WebAdministration -Force

    # Firewall rule
    Write-Host "Creando regla de firewall..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName "FTP" -Direction Inbound -LocalPort 21 -Protocol TCP -Action Allow

    #Creacion de los grupos
    Write-Host "Creando grupos necesarios para el servidor FTP..." -ForegroundColor Yellow
    New-LocalGroup -Name "reprobados" -Description "Grupo de reprobados"
    New-LocalGroup -Name "recursadores" -Description "Grupo de recursadores"

    #Creacion de carpeta fisicas del FTP
    Write-Host "Creando carpeta principal del FTP..." -ForegroundColor Yellow
    $ftpPath = "C:\FTP"
    New-Item -Path $ftpPath -ItemType Directory

    Write-Host "Creando carpetas de reprobados" -ForegroundColor Yellow
    $reprobadosPath = "C:\FTP\reprobados"
    New-Item -Path $reprobadosPath -ItemType Directory

    Write-Host "Creando carpetas de recursadores" -ForegroundColor Yellow
    $recursadoresPath = "C:\FTP\recursadores"
    New-Item -Path $recursadoresPath -ItemType Directory
    
    Write-Host "Creando carpeta general" -ForegroundColor Yellow
    $generalPath = "C:\FTP\general"
    New-Item -Path $generalPath -ItemType Directory

    #Creacion de un sitio FTP
    Write-Host "Creando sitio FTP..." -ForegroundColor Yellow
    New-webSite -Name "FTP" -Port 21 -PhysicalPath $ftpPath

    #Creacion de los directorios virtuales
    #Write-Host "Creando directorios virtuales de cada carpeta..." -ForegroundColor Yellow
    #New-WebVirtualDirectory -Site "FTP" -Name "RaizFTP" -PhysicalPath $ftpPath    
    #New-WebVirtualDirectory -Site "FTP" -Name "Reprobados" -PhysicalPath $reprobadosPath
    #New-WebVirtualDirectory -Site "FTP" -Name "Recursadores" -PhysicalPath $recursadoresPath
    #New-WebVirtualDirectory -Site "FTP" -Name "General" -PhysicalPath $generalPath
    
    #Mando llamar al gestor de usuarios
    Write-Host "Mandando llamar la funcion del gestor de usuarios..." -ForegroundColor Yellow
    gestor_usuarios

    #Configuracion de los permisos de las carpetas
    # Permitir acceso total a los grupos en sus carpetas
    Write-Host "Asignando los permisos para los grupos de reprobados..." -ForegroundColor Yellow
    icacls $reprobadosPath /grant "reprobados:(OI)(CI)F" /inheritance:r

    Write-Host "Asignando los permisos para los grupos de recursadores..." -ForegroundColor Yellow
    icacls $recursadoresPath /grant "recursadores:(OI)(CI)F" /inheritance:r

    # Permitir acceso total a los usuarios en la carpeta general
    Write-Host "Asignando los permisos para los usuarios en la carpeta publica..." -ForegroundColor Yellow
    icacls $generalPath /grant "Todos:(OI)(CI)F" /inheritance:r


    $sitioFTP = "FTP"
    # Verifica si el sitio FTP existe
    # Si existe el sitio FTP, habilita la autenticación anónima y básica
    if (Get-Website -Name $sitioFTP) {
        Write-Host "Generando las autentificaciones basica y anonima." -ForegroundColor Yellow
        Add-WebConfigurationProperty -Filter "/system.ftpServer/security/authentication/anonymousAuthentication" -Name "enabled" -Value "True" -PSPath "IIS:\Sites\$sitioFTP"
        Add-WebConfigurationProperty -Filter "/system.ftpServer/security/authentication/basicAuthentication" -Name "enabled" -Value "True" -PSPath "IIS:\Sites\$sitioFTP"
        Add-WebConfigurationProperty -Filter "/system.ftpServer/messages" -PSPath "MACHINE/WEBROOT/APPHOST" -Name "bannerMessage" -Value "Bienvenido al servidor FTP"
        Write-Host "Autenticación anónima y básica habilitada para el sitio FTP '$sitioFTP'."
    } else {
        Write-Host "El sitio FTP '$sitioFTP' no existe."
    }

    $SSLPolicy = @(
        'ftpServer.security.ssl.controlChannelPolicy',
        'ftpServer.security.ssl.dataChannelPolicy'
    )
    Set-ItemProperty "IIS:\Sites\FTP" -name $SSLPolicy[0] -value 0
    Set-ItemProperty "IIS:\Sites\FTP" -name $SSLPolicy[1] -value 0

    # Reiniciar FTP para aplicar cambios
    Write-Host "Reiniciando el servicio de FTP....." -ForegroundColor Yellow
    Restart-Service -Name FTPSVC

    #Mostrar que esta corriendo el servicio
    Write-Host "Verificando si el servicio esta corriendo...." -ForegroundColor Yellow
    Get-Service -Name FTPSVC

    #Mensaje de finalizacion
    Write-Host "Servidor FTP configurado correctamente" -ForegroundColor Green
    exit
#}
#do{
#    Write-Host "¿Qué desea hacer?"
    # Write-Host "[1].-Gestor de usuarios"
    # Write-Host "[2].-Salir"
    # $opcion = Read-Host ">" 

    # if($opcion -eq 1){
    #     gestor_usuarios
    #     Restart-Service -Name FTPSVC
    # }
    # if($opcion -eq 2){
    #     Write-Host "Saliendo..."
    #     continue
    # }
    # else{
    #     Write-Host "Opción no válida" -ForegroundColor Red
    # }

#}while($opcion -ne 1 -and $opcion -ne 2)