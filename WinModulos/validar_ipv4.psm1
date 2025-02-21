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
