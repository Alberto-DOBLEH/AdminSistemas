Import-Module ..\WinModulos\usuarios_ad.psm1

# Verificar si está instalado el rol de Active Directory Domain Services
$rol = Get-WindowsFeature -Name AD-Domain-Services

if (-not $rol.Installed) {
    Write-Host "El rol 'AD-Domain-Services' NO está instalado." -ForegroundColor Red
    try {
        # Intentar instalar el rol
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -ErrorAction Stop
        Write-Host "El rol 'AD-Domain-Services' se ha instalado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "Error al instalar el rol 'AD-Domain-Services': $($_.Exception.Message)" -ForegroundColor Red
    } 
} else {
    Write-Host "El rol 'AD-Domain-Services' está instalado." -ForegroundColor Green
}

# Verificar si el servidor es un controlador de dominio
try {
    $dominio = Get-ADDomain
    Write-Host "El servidor forma parte del dominio: $($dominio.Name)" -ForegroundColor Green
    $domainName = $dominio.DNSRoot
} catch {
    Write-Host "El servidor NO está unido a un dominio o no es un DC." -ForegroundColor Red

    # Preguntar el nombre del dominio
    $domainName = Read-Host "Ingresa el nombre de dominio que quieres crear (ej. cuates.local)"
    $netbiosName = Read-Host "Ingresa el nombre NetBIOS para el dominio (ej. CUATES)"
    try{    
        Install-ADDSForest -DomainName $domainName -DomainNetbiosName $netbiosName -SafeModeAdministratorPassword (Read-Host -AsSecureString "Ingresa la contraseña de modo seguro") -InstallDNS
        Write-Host "El servidor se ha unido al dominio '$domainName'" -ForegroundColor Green
        Set-ADUser -Identity "Administrador" -PasswordNeverExpires $true -ChangePasswordAtLogon $false

        Write-Host "Reiniciando el servidor..." -ForegroundColor Yellow
        shutdown.exe /r
        exit
    }catch{
        Write-Host "Error al unir el dominio: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Verificar existencia de las OUs 'cuates' y 'no cuates'
$ouCuates = Get-ADOrganizationalUnit -Filter 'Name -eq "cuates"' -ErrorAction SilentlyContinue
$ouNoCuates = Get-ADOrganizationalUnit -Filter 'Name -eq "no cuates"' -ErrorAction SilentlyContinue

if ($ouCuates) {
    Write-Host "La OU 'cuates' existe." -ForegroundColor Green
} else {
    Write-Host "La OU 'cuates' NO existe." -ForegroundColor Red
    try{
        New-ADOrganizationalUnit -Name "cuates" -ProtectedFromAccidentalDeletion $true
        Write-Host "La OU 'cuates' ha sido creada." -ForegroundColor Green
    }catch{
        Write-Host "Error al crear la OU 'cuates': $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($ouNoCuates) {
    Write-Host "La OU 'no cuates' existe." -ForegroundColor Green
} else {
    Write-Host "La OU 'no cuates' NO existe." -ForegroundColor Red
    try{
        New-ADOrganizationalUnit -Name "no cuates" -ProtectedFromAccidentalDeletion $true
        Write-Host "La OU 'no cuates' ha sido creada." -ForegroundColor Green
    }catch{
        Write-Host "Error al crear la OU 'no cuates': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Carpeta de usuarios moviles
$carpetaMoviles = "D:\PerfilesMoviles"
if(Test-Path $carpetaMoviles) {
    Write-Host "La carpeta de perfiles móviles ya existe." -ForegroundColor Green
}else{
    Write-Host "La carpeta de perfiles móviles no existe. Creando..." -ForegroundColor Yellow
    try{
        New-Item -Path "D:\PerfilesMoviles" -ItemType Directory
        New-SmbShare -Name "Perfiles$" -Path "D:\PerfilesMoviles" -FullAccess "Administradores"    
    }catch{
        Write-Host "Error al crear la carpeta de perfiles móviles: $($_.Exception.Message)" -ForegroundColor Red
    }
}


#Seccion de Reglas de Firewall
New-NetFirewallRule -DisplayName "Active Directory"  -Direction Inbound -Protocol TCP -LocalPort 53,88,135,389,445,636,49152-65535 -Action Allow -Profile Domain -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName "Active Directory (UDP)" -Direction Inbound -Protocol UDP -LocalPort 53,88,389 -Action Allow -Profile Domain -ErrorAction SilentlyContinue | Out-Null

do{
    Write-Host "---Menu Usuarios AD---"
    Write-Host "1. Crear usuario"
    Write-Host "2. Eliminar usuario"
    Write-Host "3. Aplicar politicas de las OUs"
    Write-Host "4. Aplicar MFA"
    write-Host "5. Salir"
    $opcion = Read-Host "Selecciona una opción"

    switch($opcion){
        1{
            crear_user_ad -dominio $domainName
        }
        2{
            eliminar_user_ad
        }
        3{
            Write-Host "Aplicando políticas de las OUs..."
            # Aquí puedes llamar a la función que aplica las políticas
            # Por ejemplo: aplicar_politicas_ou
        }
        3{
            $Usuario = Read-Host "Ingrese el nombre de usuario (incluyendo el dominio)"
            $issuer = Read-Host "Ingrese el emisor (ej. plan-tres.com)"
            configuracion_multifactor -NombreUsuario $Usuario -Issuer $issuer
        }
        5{
            Write-Host "Saliendo..."
            break
        }
        default{
            Write-Host "Opción no válida. Intente de nuevo." -ForegroundColor Red
        }    
    }
    
}while($opcion -ne 4)

