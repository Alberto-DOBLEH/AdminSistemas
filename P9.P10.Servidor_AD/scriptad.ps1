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
    Write-Host "✅ El servidor forma parte del dominio: $($dominio.Name)" -ForegroundColor Green
} catch {
    Write-Host "❌ El servidor NO está unido a un dominio o no es un DC." -ForegroundColor Red
    Install-ADDSForest -DomainName "cuates.local" -DomainNetbiosName "CUATES" -SafeModeAdministratorPassword (Read-Host -AsSecureString "Ingresa la contraseña de modo seguro")
    shutdown.exe /r
}

# Verificar existencia de las OUs 'cuates' y 'no cuates'
$ouCuates = Get-ADOrganizationalUnit -Filter 'Name -eq "cuates"' -ErrorAction SilentlyContinue
$ouNoCuates = Get-ADOrganizationalUnit -Filter 'Name -eq "no cuates"' -ErrorAction SilentlyContinue

if ($ouCuates) {
    Write-Host "✅ La OU 'cuates' existe." -ForegroundColor Green
} else {
    Write-Host "❌ La OU 'cuates' NO existe." -ForegroundColor Red
    New-ADOrganizationalUnit -Name "cuates" -ProtectedFromAccidentalDeletion $true
}

if ($ouNoCuates) {
    Write-Host "✅ La OU 'no cuates' existe." -ForegroundColor Green
} else {
    Write-Host "❌ La OU 'no cuates' NO existe." -ForegroundColor Red
    New-ADOrganizationalUnit -Name "no cuates" -ProtectedFromAccidentalDeletion $true
}

do{
    Write-Host "---Menu Usuarios AD---"
    Write-Host "1. Crear usuario"
    Write-Host "2. Modificar usuario"
    Write-Host "3. Eliminar usuario"
    write-Host "4. Salir"
    $opcion = Read-Host "Selecciona una opción"

    switch($opcion){
        1{
            Write-Host "Seccion de creacion de usuarios "
        }
        2{
            Write-Host "Seccion de modificacion de usuarios"
        }
        3{
            Write-Host "Seccion de eliminacion de usuarios"
        }
        4{
            Write-Host "Saliendo..."
            break
        }
        default{
            Write-Host "Opción no válida. Intente de nuevo." -ForegroundColor Red
        }    
    }
    
}while($opcion -ne 4)

