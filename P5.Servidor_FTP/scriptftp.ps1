#Importacion de modulos
Import-Module ../WinModulos/validaciones.psm1
Import-Module ../WinModulos/usuarios.psm1

#Verificacion Inicial del servicio FTP 
$serviceName = "FTPSVC"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -ne $service) {
    Write-Host "El servicio FTP ya está instalado."
} else {
    Write-Host "El servicio FTP no está instalado. Procediendo a la instalación..."
   
    #Instalacion de los servcios para el servidor FTP
    Install-WindowsFeature Web-FTP-Server -IncludeManagementTools
    Install-WindowsFeature Web-Server -IncludeManagementTools
    Import-Module WebAdministration

    #Creacion de los grupos
    New-LocalGroup -Name "reprobados" -Description "Grupo de reprobados"
    New-LocalGroup -Name "recursadores" -Description "Grupo de recursadores"

    #Creacion de carpeta raiz del FTP
    $ftpPath = "C:\FTP"
    New-Item -Path $ftpPath -ItemType Directory

    #Creacion de carpetas obligatorias del FTP
    $reprobadosPath = "C:\FTP\reprobados"
    $recursadoresPath = "C:\FTP\recursadores"
    $generalPath = "C:\FTP\general"
    New-Item -Path $reprobadosPath -ItemType Directory
    New-Item -Path $recursadoresPath -ItemType Directory
    New-Item -Path $generalPath -ItemType Directory

    #Creacion de un sitio FTP
    New-webSite -Name "FTP" -Port 21 -PhysicalPath $ftpPath -Server localhost

    #Configuracion de los permisos de las carpetas
    # Permitir acceso total a los grupos en sus carpetas
    icacls $reprobadosPath /grant "reprobados :(OI)(CI)F" /inheritance:r
    icacls $recursadoresPath /grant "recursadores :(OI)(CI)F" /inheritance:r

    # Permitir acceso total a los usuarios en la carpeta general
    icacls $generalPath /grant "Usuarios:(OI)(CI)F" /inheritance:r
    icacls $generalPath /grant "IUSR:(OI)(CI)F" /inheritance:r  # Permite acceso anónimo

    # Verificar si se instaló correctamente
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        Write-Host "El servicio FTP se instaló correctamente."
    } else {
        Write-Host "Error al instalar el servicio FTP."
    }
    gestor_usuarios
}
do{
    Write-Host "¿Qué desea hacer?"
    Write-Host "Gestor de usuarios"
    Write-Host "Salir"

}


