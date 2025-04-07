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
        # Escribe el archivo USER.INI con codificación ANSI (Default = ANSI en Windows)
        $userIniPath = Join-Path $userPath "USER.INI"
        $bytes = [System.Text.Encoding]::Default.GetBytes($userIni)
        [System.IO.File]::WriteAllBytes($userIniPath, $bytes)

        Write-Host "Usuario '$nombre' creado correctamente."
    }
}