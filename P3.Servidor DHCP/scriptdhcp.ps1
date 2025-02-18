
$regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$"
$ipserver = ""
do{
    $ipserver = Read-Host "Ingrese la ip que quiere para el servidor " 

    if ($ipserver -match $regex){
        Write-Host "La IP es valida" -ForegroundColor Green
        $valida = $true
    }else {
        Write-Host "La IP es no es valida, favor de ingresar otra" -ForegroundColor Green
        $valida = $false
    }
}while(-not $valida)

$iniciorango = ""
do{
    $iniciorango = Read-Host "Ingrese la ip de inicio del rango " 

    if ($iniciorango -match $regex){
        Write-Host "La IP es valida" -ForegroundColor Green
        $valida = $true
    }else {
        Write-Host "La IP es no es valida, favor de ingresar otra" -ForegroundColor Green
        $valida = $false
    }
}while(-not $valida)

$finalrango= ""
do{
    $finalrango = Read-Host "Ingrese la ip del final del rango " 

    if ($finalrango -match $regex){
        Write-Host "La IP es valida" -ForegroundColor Green
        $valida = $true
    }else {
        Write-Host "La IP es no es valida, favor de ingresar otra" -ForegroundColor Green
        $valida = $false
    }
}while(-not $valida)

$nombre = ""
do{
    $nombre = Read-Host "Ingrese nombre para la red:  " 
    
    if( -not [string]::IsNullOrEmpty($nombre)){
        Write-Host "Dominio Valido" -ForegroundColor Green
        Break
    }else{
        Write-Host "El dominio no puede ser vacio" -ForegroundColor Green
    }

}While($true)

function Get-NetworkDetails {
    param (
        [string]$IPAddress,
        [int]$CIDR = 24  # Valor predeterminado si no se especifica
    )

    # Validar IP
    if ($IPAddress -notmatch "^\d{1,3}(\.\d{1,3}){3}$") {
        Write-Host "Error: IP inválida. Introduce una IP válida." -ForegroundColor Red
        return
    }

    # Tabla de máscaras de subred según el prefijo CIDR
    $subnetMasks = @{
        8  = "255.0.0.0"; 9  = "255.128.0.0"; 10 = "255.192.0.0"; 11 = "255.224.0.0"; 12 = "255.240.0.0"
        13 = "255.248.0.0"; 14 = "255.252.0.0"; 15 = "255.254.0.0"; 16 = "255.255.0.0"; 17 = "255.255.128.0"
        18 = "255.255.192.0"; 19 = "255.255.224.0"; 20 = "255.255.240.0"; 21 = "255.255.248.0"; 22 = "255.255.252.0"
        23 = "255.255.254.0"; 24 = "255.255.255.0"; 25 = "255.255.255.128"; 26 = "255.255.255.192"; 27 = "255.255.255.224"
        28 = "255.255.255.240"; 29 = "255.255.255.248"; 30 = "255.255.255.252"; 31 = "255.255.255.254"; 32 = "255.255.255.255"
    }

    # Obtener la máscara de subred
    if (-not $subnetMasks.ContainsKey($CIDR)) {
        Write-Host "Error: Prefijo CIDR inválido. Debe estar entre 8 y 32." -ForegroundColor Red
        return
    }
    $subnetMask = $subnetMasks[$CIDR]

    # Calcular la dirección de red (último octeto en 0)
    $octets = $IPAddress -split "\."
    $networkAddress = "$($octets[0]).$($octets[1]).$($octets[2]).0"

    # Guardar en variables globales
    $global:SubnetMask = $subnetMask
    $global:NetworkIP = $networkAddress
}

Get-NetworkDetails -IPAddress $ipserver

#Asignacion de IP Estatica al segundo adaptador de la red local
Write-Host "Poniendo la IP estatica para el servidor local...." -ForegroundColor Green
New-NetIPAddress -InterfaceAlias 'Ethernet 2' -IPAddress $ipserver -PrefixLength 24

#Instalacion del servicio
Write-Host "Instalando el servicio de DHCP...." -ForegroundColor Green
Install-WindowsFeature -Name DHCP -IncludeManagementTools

#Configuracion DHCP
Write-Host "Asignando las configuraciones del DHCP..." -ForegroundColor Green
Add-DhcpServerv4Scope -Name $nombre -StartRange $iniciorango -EndRange $finalrango -SubnetMask $SubnetMask -State Active
Set-DhcpServerv4OptionValue -ScopeId $NetworkIP -OptionId 3 -Value $ipserver

Write-Host "Reiniciando el servicio de DHCP..." -ForegroundColor Green
Restart-Service -Name DHCP -Force

Write-Host "Verificacion de si esta corriendo..." -ForegroundColor Green
Get-Service -Name DHCP
