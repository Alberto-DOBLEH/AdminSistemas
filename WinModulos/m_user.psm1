function crear_usuario{
    param(
        [string]$nombre,
        [string]$contra
    )
    $mercuryMailPath = "C:\Mercury\Mail"

    # Ruta del usuario
    $userPath = Join-Path $mercuryMailPath $nombre
    # Verifica si ya existe
    if (Test-Path $userPath) {
        Write-Host "El usuario '$nombre' ya existe."
    } else {
        # Crea carpeta del usuario
        New-Item -Path $userPath -ItemType Directory -Force | Out-Null
    
        # Contenido del USER.INI
        $userIni = @"
[User]
Name=$nombre
Password=$contra
"@
    
        # Escribe el archivo USER.INI
        $userIniPath = Join-Path $userPath "USER.INI"
        $userIni | Set-Content -Path $userIniPath -Encoding ASCII
    
        Write-Host "Usuario '$username' creado correctamente."
    }
}