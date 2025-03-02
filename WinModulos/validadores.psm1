function validar_ipv4 {
    param (
        [string]$IP
    )

    $regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$"

    if ($IP -match $regex) {
        Write-Host "La IP es válida" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "La IP no es válida, favor de ingresar otra" -ForegroundColor Red
        return $false
    }
}
function detalles_red {
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

    return@($subnetMask,$networkAddress)
}

#Validacion por textos vacios
function validar_textos_nulos{
    param (
        [string]$texto
    )
    write-Host $texto
    if( -not [string]::IsNullOrEmpty($texto)){
        return $true
    }else{
        return $false
    }
}
#Validacion de que el username no tenga espacios
function validar_espacios {
    param(
        [string]$usuario
    )

    write-Host $usuario
    if( $usuario -match "\s"){
        return $false
    }else{
        return $true
    }
}
#validcacion de formato de contrasena
function validar_contrasena {
    param (
        [string]$contrasena
    )

    write-Host $contrasena
    if ($contrasena.Length -lt 8) {
        return $false
    }

    if ($contrasena -notmatch "[A-Z]") {
        return $false
    }

    if ($contrasena -notmatch "[0-9]") {
        return $false
    }

    return $true
}

#Validacion de que el usuario ya existe
function validar_usuario_existente {
    param (
        [string]$usuario
    )

    write-Host $usuario
    try {
        Get-ADUser -Filter "SamAccountName -eq '$usuario'" -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

#Validacion de que exista el grupo
function validar_grupo_existente {
    param (
        [string]$nombreGrupo
    )

    try {
        Get-ADGroup -Filter "Name -eq '$nombreGrupo'" -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

#Validacion de que 