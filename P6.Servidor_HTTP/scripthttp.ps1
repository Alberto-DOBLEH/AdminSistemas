Import-Module ../WinModulos/IIS.psm1
Import-Module ../WinModulos/Nginx.psm1
Import-Module ../WinModulos/Tomcat.psm1

do{
    Write-Host "----Servidor HTTP-----"
    Write-Host "¿Que servicio desea utilizar?"
    Write-Host "[1].-IIS"
    Write-Host "[3].-Nginx"
    Write-Host "[2].-Tomcat"
    Write-Host "[4].-Salir del script.."
    $opc = Read-Host "Ingrese su opcion:" 

    switch($opc){
        1 {
            Write-Host "Pasando con la seccion de IIS...."
            IIS
        }
        2{
            Write-Host "Pasando con la seccion de Nginx...."
        }
        3{
            Write-Host "Pasando con la seccion de Tomcat...."
        }
        4 {
            Write-Host "Saliendo...."
        }
        Default{
            Write-Host "Opcion no valida. Favor de ingresar una opcion del 1 al 4"
        }
    }
}while($opc -ne 4)
