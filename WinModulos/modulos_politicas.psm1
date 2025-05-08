function horarios{

    # OU cuates de 6am a 3pm
    $ou = "OU=cuates,DC=cuate,DC=local"

    $horassesion = @()
    for ($dia = 0; $dia -lt 7; $dia++) {
        $horasdia = @(0..23 | ForEach-Object {
            if ($_ -ge 8 -and $_ -lt 15) { 1 } else { 0 }
        })
        $horassesion += ,$horasdia
    }

    $horasplanas = $horassesion | ForEach-Object { $_ }
    $horassesionbytes = for ($i = 0; $i -lt 168; $i += 8) {
        [byte]([Convert]::ToByte(($horasplanas[$i..($i + 7)] -join ''), 2))
    }

    Get-ADUser -SearchBase $ou -Filter * | ForEach-Object {
        Set-ADUser $_ -LogonHours $horassesionbytes
        Write-Host "Restricción de horario aplicada a $($_.SamAccountName)"
    }

    # OU no cuates de 3pm a 2am
    $ou = "OU=no cuates,DC=cuate,DC=local"

    # Crear una matriz de 7 días x 24 horas (domingo a sábado)
    $horario = @()

    for ($dia = 0; $dia -lt 7; $dia++) {
        $horas = @()

        # Horas de 0 a 23
        for ($hora = 0; $hora -lt 24; $hora++) {
            if ($hora -ge 15) {
                # Parte del rango: 15:00 a 23:59 del día actual
                $horas += 1
            } elseif ($hora -lt 2) {
                # Parte del rango: 00:00 a 01:59 del día siguiente
                # Se agregará al día anterior
                $horas += 1
            } else {
                $horas += 0
            }
        }

        $horario += ,$horas
    }

    # Reorganizar correctamente para representar el cruce de días
    for ($dia = 0; $dia -lt 7; $dia++) {
        for ($hora = 0; $hora -lt 24; $hora++) {
            # Si la hora es 0 o 1, esa parte pertenece al día anterior
            if ($hora -lt 2) {
                $diaanterior = ($dia - 1) % 7
                if ($diaanterior -lt 0) { $diaanterior += 7 }
                $horario[$diaanterior][$hora] = 1
                $horario[$dia][$hora] = 0
            }
        }
    }

    # Aplanar y convertir a bytes
    $horasaplanadas = $horario | ForEach-Object { $_ }
    $horarioBytes = for ($i = 0; $i -lt 168; $i += 8) {
        [byte]([Convert]::ToByte(($horasaplanadas[$i..($i + 7)] -join ''), 2))
    }

    # Aplicar a todos los usuarios en la OU
    Get-ADUser -SearchBase $ou -Filter * | ForEach-Object {
        Set-ADUser $_ -LogonHours $horarioBytes
        Write-Host "Restricción de horario aplicada a $($_.SamAccountName)"
    }

}

function archivos_limitados{

    # OU cuates archivos de 5MB

    # OU no cuates archivos de 10MB
}

function acceso_aplicaciones{

    # OU cuates acceso a bloc de notas

    # OU no cuates sin acceso a bloc de notas
}

function configuracion_multifactor{
    # Habilitar MFA en la configuración de los usuarios en el AD
    param (
        [string]$NombreUsuario = '',
        [string]$Issuer = 'plan-tres.com'
    )

    # Definir el alfabeto Base32
    $Script:Base32Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

    # Generar clave secreta en Base32
    $SecretLength = 10
    $byteArrayForSecret = [byte[]]::new($SecretLength)
    [Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($byteArrayForSecret, 0, $SecretLength)

    $binaryString = -join $byteArrayForSecret.ForEach{
        [Convert]::ToString($_, 2).PadLeft(8, '0')
    }

    $Base32Secret = [regex]::Replace($binaryString, '.{5}', {
        param($Match)
        $Script:Base32Charset[[Convert]::ToInt32($Match.Value, 2)]
    })

    # Construir URI TOTP
    $otpUri = "otpauth://totp/{0}?secret={1}&issuer={2}" -f (
        [Uri]::EscapeDataString($NombreUsuario),
        $Base32Secret,
        [Uri]::EscapeDataString($Issuer)
    )

    $encodedUri = [Uri]::EscapeDataString($otpUri)
    $qrCodeUri = "https://api.qrserver.com/v1/create-qr-code/?size200x200&data=$encodedUri"

    $NombreUsuario = Read-Host "Ingrese el nombre de usuario (incluyendo el dominio)"

    # Mostrar datos
    Write-Host "`n--- Configuración MFA ---"
    Write-Host "Usuario         : $NombreUsuario"
    Write-Host "Emisor          : $Issuer"
    Write-Host "Secreto         : $Base32Secret"
    Write-Host "URI TOTP        : $otpUri"
    Write-Host "QR para escanear:"
    Write-Host $qrCodeUri

    # Opcional: Abrir el navegador automáticamente
    Start-Process $qrCodeUri

    return [PSCustomObject]@{
        Usuario    = $NombreUsuario
        Issuer     = $Issuer
        Secreto    = $Base32Secret
        QrCode     = $qrCodeUri
    }
}

function configuracion_auditorias{
    # Habilitar auditorías de accesos y cambios en el AD
}