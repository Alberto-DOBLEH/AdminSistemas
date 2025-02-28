Import-Module ./validaciones.psm1

function gestor_usuarios{
    
    Write-Host "--Menu de usuarios--"
    Write-Host "[1].- Crear usuario"
    Write-Host "[2].- Eliminar usuario"
    Write-Host "[3].- Cambiar de grupo usuario"
    Write-Host "[4].- Salir"
    Read-Host opc

    switch ($opc) {
        1 {
            #--------------------------------------
            #            Crear usuarios
            #--------------------------------------

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

                $vu3 = validar_usuario_existente -usuario $usuario
                if($vu3 -eq $true){
                    Write-Host "Error: El usuario ya existe" -ForegroundColor Red
                    continue
                }

            }While($vu1 -eq $false -or $vu2 -eq $false -or $vu3 -eq $true)

            $password = ""
            do{            
                $password = Read-Host "Ingresa la contraseña"

                $vc1 = validar_textos_nulos -texto $password
                if($vc1 -eq $false){
                    Write-Host "Error: La contraseña no puede estar vacía" -ForegroundColor Red
                    continue
                }
                
                $vc2 = validar_espacios -usuario $password
                if($vc2 -eq $false){
                    Write-Host "Error: La contraseña no puede contener espacios" -ForegroundColor Red
                    continue
                }

                $vc3 = validar_contraseña -contraseña $password
                if($vc3 -eq $false){
                    Write-Host "Error: La contraseña debe tener al menos 8 caracteres, una letra mayúscula y un número" -ForegroundColor Red
                    continue
                }

            }While($vc1 -eq $false -or $vc2 -eq $false -or $vc3 -eq $false)

            Write-Host "Creando usuario....." -ForegroundColor Green
            New-LocalUser -Name $usuario -Password (-AsSecureString $password) -FullName "$($usuario) SSH" -Description "Usuario " -PasswordNeverExpires 
            Add-LocalGroupMember -Group "Usuarios" -Member $usuario       
            Write-Host "Usuario creado correctamente" -ForegroundColor Green

            #Creacion de carpeta personal
            $userpath = "C:\FTP\$usuario"
            New-Item -Path $userpath -ItemType Directory

            #Agregar el usuario a un grupo
            do{
            Write-Host "A que grupo desea agregarlo?"
            Write-Host "[1].- reprobados"
            Write-Host "[2].- recursadores"
            Read-Host grupo

            switch ($grupo) {
                1 {
                    Add-LocalGroupMember -Group "reprobados" -Member $usuario
                    Write-Host "Usuario agregado al grupo reprobados" -ForegroundColor Green
                    $grp = "reprobados"
                }
                2 {
                    Add-LocalGroupMember -Group "recursadores" -Member $usuario
                    Write-Host "Usuario agregado al grupo recursadores" -ForegroundColor Green
                    $grp = "recursadores"
                }
                Default {
                    Write-Host "Opción no válida" -ForegroundColor Red
                }
            }
            }while($grupo -ne 1 -and $grupo -ne 2)

            #Asignacion de permisos
            # Configurar permisos para que SOLO el usuario y su grupo accedan a su carpeta
            icacls $userFolder /grant "$usuario :(OI)(CI)F" /inheritance:r
            icacls $userFolder /grant "$grp :(OI)(CI)F" /inheritance:r

            # Conceder acceso del usuario a la carpeta pública
            icacls "C:\FTP\Publico" /grant "$usuario :(OI)(CI)F" /inheritance:r

            # Configurar IIS para que el usuario FTP vea solo su carpeta personal
            $ftpuserpath = "IIS:\Sites\FTP-Site\$usuario"
            if (-not (Test-Path $ftpuserpath)) {
                New-WebVirtualDirectory -Site "FTP-Site" -Name $usuario -PhysicalPath $userpath
            }

        }
        2 { 
            #--------------------------------------
            #          Eliminar usuarios
            #--------------------------------------
            
            
        }
        3 { 
            #--------------------------------------
            #           Editar usuarios
            #--------------------------------------

        }
        4 { 

        }
    }


}