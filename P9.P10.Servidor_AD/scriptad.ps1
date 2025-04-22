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
} catch {
    Write-Host "El servidor NO está unido a un dominio o no es un DC." -ForegroundColor Red
    try{    
        Install-ADDSForest -DomainName "cuates.local" -DomainNetbiosName "CUATES" -SafeModeAdministratorPassword (Read-Host -AsSecureString "Ingresa la contraseña de modo seguro")
        Write-Host "El servidor se ha unido al dominio 'cuates.local'." -ForegroundColor Green
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

do{
    Write-Host "---Menu Usuarios AD---"
    Write-Host "1. Crear usuario"
    Write-Host "2. Eliminar usuario"
    write-Host "3. Salir"
    $opcion = Read-Host "Selecciona una opción"

    switch($opcion){
        1{
            crear_user_ad
        }
        2{
            eliminar_user_ad
        }
        3{
            Write-Host "Saliendo..."
            break
        }
        default{
            Write-Host "Opción no válida. Intente de nuevo." -ForegroundColor Red
        }    
    }
    
}while($opcion -ne 3)

