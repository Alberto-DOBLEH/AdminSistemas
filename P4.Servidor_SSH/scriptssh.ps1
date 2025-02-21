#Importacion de modulos
Write-Host "Importando modulo de validacion de IP" -ForegroundColor Green
Import-Module "C:\Users\Administrador\Desktop\SysAdmin\AdminSistemas\WinModulos\validar_ipv4.psm1"

#Instalar OpenSSH
Write-Host "Instalando OpenSSH" -ForegroundColor Green
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Get-Module -ListAvailable -Name NetSecurity

#Verificar si OpenSSH está instalado
Write-Host "Verificando si OpenSSH está instalado" -ForegroundColor Green
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

#Iniciar el servicio
Write-Host "Iniciando el servicio de OpenSSH" -ForegroundColor Green
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

#Modificar el firewall
Write-Host "Modificando el firewall para permitir el acceso SSH" -ForegroundColor Green
New-NetFirewallRule -Name "SSH" -DisplayName 'OpenSSH Server' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow 

#Definir la IP del servidor SSH
$ipserver = ""
do {
    $ipserver = Read-Host "Ingrese la IP para el servidor SSH"
} while (-not (validar_ipv4 $ipserver))

#Asignacion de IP Estatica al segundo adaptador de la red local
Write-Host "Poniendo la IP estatica para el servidor SSH...." -ForegroundColor Green
New-NetIPAddress -InterfaceAlias 'Ethernet 2' -IPAddress $ipserver -PrefixLength 24

#Creacion del usuario
$usuario = ""
do{
    $usuario = Read-Host "Ingrese el usuario para el SSH" 
    
    if( -not [string]::IsNullOrEmpty($Usuario)){
        Write-Host "Usuario Valido" -ForegroundColor Green
        Break
    }else{
        Write-Host "El nombre no puede ser vacio" -ForegroundColor Red
    }
}While($true)

$password = Read-Host -AsSecureString "Ingresa la contraseña"

Write-Host "Creando usuario para SSH" -ForegroundColor Green
New-LocalUser -Name $usuario -Password $password -FullName "$($usuario) SSH" -Description "Usuario para acceso SSH" -PasswordNeverExpires $true

#Agregar usuario a los grupos necesarios
Write-Host "Agregando usuario a los grupos necesarios" -ForegroundColor Green
Add-LocalGroupMember -Group "Usuarios" -Member $usuario
Add-LocalGroupMember -Group "Usuarios de OpenSSH" -Member $usuario
