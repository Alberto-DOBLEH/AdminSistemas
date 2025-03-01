#Importacion de modulos
Import-Module ../WinModulos/validadores.psm1
Import-Module ../WinModulos/usuarios.psm1

#Verificacion Inicial del servicio FTP 
$serviceName = "FTPSVC"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -ne $service) {
    Write-Host "El servicio FTP ya está instalado."
} else {
    Write-Host "El servicio FTP no está instalado. Procediendo a la instalación..."
   
    #Instalacion de los servcios para el servidor FTP
    Write-Host "Instalando servicios necesarios para el servidor FTP..." -ForegroundColor Yellow
    Install-WindowsFeature Web-FTP-Server -IncludeManagementTools
    Install-WindowsFeature Web-Server -IncludeManagementTools
    Import-Module WebAdministration

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
    New-webSite -Name "FTP" -Port 21 -PhysicalPath $ftpPath -Server WIN-KDHI103607G


    #Creacion de los directorios virtuales
    Write-Host "Creando directorios virtuales de cada carpeta..." -ForegroundColor Yellow
    New-WebVirtualDirectory -Site "FTP" -Name "RaizFTP" -PhysicalPath $ftpPath    
    New-WebVirtualDirectory -Site "FTP" -Name "Reprobados" -PhysicalPath $reprobadosPath
    New-WebVirtualDirectory -Site "FTP" -Name "Recursadores" -PhysicalPath $recursadoresPath
    New-WebVirtualDirectory -Site "FTP" -Name "General" -PhysicalPath $generalPath -AllowAnonymous

    #Configuracion de los permisos de las carpetas
    # Permitir acceso total a los grupos en sus carpetas
    icacls $reprobadosPath /grant "reprobados :(OI)(CI)F" /inheritance:r
    icacls $recursadoresPath /grant "recursadores :(OI)(CI)F" /inheritance:r

    # Permitir acceso total a los usuarios en la carpeta general
    icacls $generalPath /grant "Usuarios:(OI)(CI)F" /inheritance:r
    icacls $generalPath /grant "IUSR:(OI)(CI)F" /inheritance:r

    Set-WebConfigurationProperty -Filter "/system.ftpServer/security/authentication/anonymousAuthentication" -Name "enabled" -Value "True" -PSPath IIS:\ 
    Set-WebConfigurationProperty -Filter "/system.ftpServer/security/authentication/basicAuthentication" -Name "enabled" -Value "True" -PSPath IIS:\

    # Reiniciar FTP para aplicar cambios
    Restart-Service FTPSVC

    #Mando llamar al gestor de usuarios
    gestor_usuarios

    #Mostrar que esta corriendo el servicio
    Get-Service -Name $serviceName

    #Mensaje de finalizacion
    Write-Host "Servidor FTP configurado correctamente" -ForegroundColor Green
    exit
}
do{
    Write-Host "¿Qué desea hacer?"
    Write-Host "[1].-Gestor de usuarios"
    Write-Host "[2].-Salir"
    $opcion = Read-Host ">" 

    if($opcion -eq 1){
        gestor_usuarios
        Restart-Service FTPSVC
    }
    if($opcion -eq 2){
        Write-Host "Saliendo..."
        continue
    }
    else{
        Write-Host "Opción no válida" -ForegroundColor Red
    }

}while($opcion -ne 1 -and $opcion -ne 2)