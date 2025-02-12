Write-Host "Se comienza a instalar el Servicio de DNS"
Install-WindowsFeature -Name DNS -IncludeManagementTools

Write-Host "Verificando si esta instalado correctamente"
Get-WindowsFeature -Name DNS

$dominio = ""
do{
    $dominio = Read-Host "Ingrese el dominio con terminacion .com: " 
    
    if([string]::IsNullOrWhiteSpace($dominio)){
        Write-Host "El dominio no púede ser vacio"
    }elseif($dominio -match "\.com$"){
        Write-Host "Dominio Valido"
        Break
    }else{
        Write-Host "El dominio no tiene la terminacion correcta"
    }

}While($true)


$ip = ""
$regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$"
do{
    $ip = Read-Host "Ingrese la ip con las separaciones de punto: " 

    if ($ip -match $regex){
        Write-Host "La IP es valida"
        $valida = $true
    }else {
        Write-Host "La IP es no es valida, favor de ingresar otra"
        $valida = $false
    }
}while(-not $valida)


Add-DnsServerPrimaryZone -Name "$($dominio)" -ZoneFile "$($dominio).dns" -DynamicUpdate NonsecureAndSecure
Write-Host "Se registro la Primary Zone del dominio junto con su Zone File en el servidor"

Add-DnsServerResourceRecordA -Name "@" -ZoneName $dominio -IPv4Address $ip
Add-DnsServerResourceRecordA -Name www -ZoneName $dominio -IPv4Address $ip
Write-Host "Se genero los Record del dominio con su IP"

Write-Host "Reinicionado el servicio de DNS"
Restart-Service -Name DNS
Write-Host "Reestablecido servicio de DNS"
Read-Host "Presione una tecla para salir...."




