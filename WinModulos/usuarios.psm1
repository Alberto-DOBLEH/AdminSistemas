Import-Module ./modulos.psm1

function usuarios{
    
    Write-Host "--Menu de usuarios--"
    Write-Host "[1].- Crear usuario"
    Write-Host "[2].- Eliminar usuario"
    Write-Host "[3].- Cambiar de grupo usuario"
    Write-Host "[4].- Salir"
    Read-Host opc

    switch ($opc) {
        1 {
            $usuario = ""
            do{
                $usuario = Read-Host "Ingrese el nombre del usuario"

                $vu1 = validar_textos_nulos -texto $usuario
                if($vu1 -eq $false){
                    Write-Host "Error: El nombre de usuario no puede estar vacío" -ForegroundColor Red
                    continue
                }
                
                $vu2 = validar_espacios -usuario $usuario
                if($vu2 -eq $false){
                    Write-Host "Error: El nombre de usuario no puede contener espacios" -ForegroundColor Red
                    continue
                }

            }While($vu1 -eq $false -or $vu2 -eq $false)

            $password = ""
            do{            
                $password = Read-Host "Ingresa la contraseña"

                $vc1 = validar_textos_nulos -texto $password
                if($vc1 -eq $false){
                    Write-Host "Error: La contraseña no puede estar vacía" -ForegroundColor Red
                    continue
                }
                
                $vc2 = validar_contraseña -contraseña $password
                if($vc2 -eq $false){
                    Write-Host "Error: La contraseña debe tener al menos 8 caracteres, una letra mayúscula y un número" -ForegroundColor Red
                    continue
                }
            }While($vc1 -eq $false -or $vc2 -eq $false)

            Write-Host "Creando usuario....." -ForegroundColor Green
            New-LocalUser -Name $usuario -Password $password -FullName "$($usuario) SSH" -Description "Usuario para acceso SSH" -PasswordNeverExpires        
        }
        2 { 
            
            
        }
        3 { 

        }
        4 { 

        }
        Default {}
    }


}