Import-Module ..\WinModulos\mercury.psm1
Import-Module ..\WinModulos\m_user.psm1
Import-Module ..\WinModulos\XAMPP.psm1
Import-Module ..\WinModulos\ardillacorreo.psm1


do{
    Write-Host "Que desea hacer?"
    Write-Host "[1].-Instalar Mercury"
    Write-Host "[2].-Crear usuario"
    Write-Host "[3].-Salir"
    $opc = Read-Host "Eleccion: "
    switch($opc){
        1{
            Write-Host "Instalando Mercury..." -ForegroundColor Green
            install_mercury
            Write-Host "Mercury instalado correctamente." -ForegroundColor Green
            Write-Host "Instalando XAMPP..." -ForegroundColor Green
            install_xampp
            Write-Host "XAMPP instalado correctamente." -ForegroundColor Green
            Write-Host "Instalando SquirrelMail..." -ForegroundColor Green
            install_squirrel
            Write-Host "SquirrelMail instalado correctamente." -ForegroundColor Green
            Start-Process "C:\xampp\apache_start.bat"
        }
        2{
            Write-Host "Seccion de creacion de usuario" -ForegroundColor Yellow
            $nombre = Read-Host "Nombre de usuario: "
            $password = Read-Host "Password: "
            crear_usuario -nombre $nombre -contra $password
            Write-Host "Usuario creado correctamente." -ForegroundColor Green
        }
        3{
            Write-Host "Saliendo..." -ForegroundColor Yellow
        }
        default{
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }
}while($opc -ne 3)