Import-Module "$PSScriptRoot/validadores.psm1"
function gestor_usuarios{
    
    do{
        Write-Host "--Menu de usuarios--"
        Write-Host "[1].- Crear usuario"
        Write-Host "[2].- Eliminar usuario"
        Write-Host "[3].- Cambiar de grupo usuario"
        Write-Host "[4].- Salir"
        $opc = Read-Host ">"

        switch ($opc) {
            1 {
                #--------------------------------------
                #            Crear usuarios
                #--------------------------------------
                do{
                    $usuario = ""
                    do{
                        $usuario = Read-Host "Ingrese el nombre del usuario"

                        Write-Host $usuario
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
                        $password = Read-Host "Ingresa la contrasena"

                        $vc1 = validar_textos_nulos -texto $password
                        if($vc1 -eq $false){
                            Write-Host "Error: La contrasena no puede estar vacía" -ForegroundColor Red
                            continue
                        }
                        
                        $vc2 = validar_espacios -usuario $password
                        if($vc2 -eq $false){
                            Write-Host "Error: La contrasena no puede contener espacios" -ForegroundColor Red
                            continue
                        }

                        $vc3 = validar_contrasena -contrasena $password
                        if($vc3 -eq $false){
                            Write-Host "Error: La contrasena debe tener al menos 8 caracteres, una letra mayúscula y un número" -ForegroundColor Red
                            continue
                        }

                    }While($vc1 -eq $false -or $vc2 -eq $false -or $vc3 -eq $false)

                    Write-Host "Creando usuario....." -ForegroundColor Green
                    New-LocalUser -Name $usuario -Password (ConvertTo-SecureString -String $password -AsPlainText -Force) -FullName "$($usuario) SSH" -Description "Usuario " -PasswordNeverExpires 
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
                        $grupo = Read-Host ">"

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
                    icacls $userpath /grant "$usuario :(OI)(CI)F" /inheritance:r
                    icacls $userpath /grant "$grp :(OI)(CI)F" /inheritance:r

                    # Conceder acceso del usuario a la carpeta pública
                    icacls "C:\FTP\General" /grant "$usuario :(OI)(CI)F" /inheritance:r

                    # Configurar IIS para que el usuario FTP vea solo su carpeta personal
                    $ftpuserpath = "IIS:\Sites\FTP\$usuario"
                    if (-not (Test-Path $ftpuserpath)) {
                        New-WebVirtualDirectory -Site "FTP" -Name $usuario -PhysicalPath $userpath
                    }
                    do{
                        Write-Host "Desea crear otro usuario? "
                        $ver= Read-Host "<S/N>"
                        $ver=$ver.ToUpper()
                    }while($ver -ne "S" -and $ver -ne "N")
                }while($ver -eq "S")
            }
            2 { 
                #--------------------------------------
                #          Eliminar usuarios
                #--------------------------------------
                do{
                    $usuario = ""
                    do{
                        $usuario = Read-Host "Ingrese el nombre del usuario a eliminar"

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
                        if($vu3 -eq $false){
                            Write-Host "Error: El usuario no existe" -ForegroundColor Red
                            continue
                        }
                    }While($vu1 -eq $false -or $vu2 -eq $false -or $vu3 -eq $false)

                    try{
                        Write-Host "Eliminando usuario....." -ForegroundColor Green
                        Remove-LocalUser -Name $usuario -Confirm:$false
                        Write-Host "Usuario eliminado correctamente" -ForegroundColor Green
                    }
                    catch{
                        Write-Host "Error inesperado" -ForegroundColor Red
                    }
                    do{
                        Write-Host "Desea eliminar otro usuario? "
                        $ver= Read-Host "<S/N>"
                        $ver=$ver.ToUpper()
                    }while($ver -ne "S" -and $ver -ne "N")
                }while($ver -eq "S")
            }
            3 { 
                #--------------------------------------
                #           Editar usuarios
                #--------------------------------------
                do{
                    $usuario=""
                    do{
                        $usuario = Read-Host "Ingrese el nombre del usuario a cambiar de grupo"

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
                        if($vu3 -eq $false){
                            Write-Host "Error: El usuario no existe" -ForegroundColor Red
                            continue
                        }
                    }While($vu1 -eq $false -or $vu2 -eq $false -or $vu3 -eq $false)

                    try {
                        # Obtener los grupos actuales del usuario
                        $gruposActuales = Get-LocalGroupMember -Name $usuario -ErrorAction Stop | Select-Object -ExpandProperty GroupName
                
                        if ($gruposActuales.Count -eq 0) {
                            Write-Host "El usuario '$usuario' no pertenece a ningún grupo local." -ForegroundColor Yellow
                            return
                        }
                
                        # Determinar el nuevo grupo
                        if ($gruposActuales -contains "reprobados") {
                            $nuevoGrupo = "recursadores"
                            $grupoAntiguo = "reprobados"
                        } elseif ($gruposActuales -contains "recursadores") {
                            $nuevoGrupo = "reprobados"
                            $grupoAntiguo = "recursadores"
                        } else {
                            Write-Host "El usuario '$usuario' no pertenece a 'reprobados' ni 'recursadores'." -ForegroundColor Yellow
                            return
                        }
                
                        # Solicitar confirmación
                        $confirmacion = Read-Host "Desea cambiar el usuario '$usuario' de '$grupoAntiguo' a '$nuevoGrupo'? (S/N)"
                        $confirmacion = $confirmacion.ToUpper()
                
                        if ($confirmacion -eq "S" -or $confirmacion -eq "s") {
                            # Cambiar el usuario de grupo
                            Remove-LocalGroupMember -Group $grupoAntiguo -Member $usuario -ErrorAction SilentlyContinue
                            Add-LocalGroupMember -Group $nuevoGrupo -Member $usuario -ErrorAction Stop
                            Write-Host "Usuario '$usuario' cambiado a '$nuevoGrupo' correctamente." -ForegroundColor Green
                        } else {
                            Write-Host "Cambio de grupo cancelado." -ForegroundColor Yellow
                        }
                    }
                    catch {
                        Write-Host "Error al cambiar el usuario de grupo: $($_.Exception.Message)" -ForegroundColor Red
                    }
                    do{
                        Write-Host "Desea cambiar a otro usuario de grupo?"
                        $ver= Read-Host "<S/N>"
                        $ver=$ver.ToUpper()
                    }while($ver -ne "S" -and $ver -ne "N")
                }while($ver -eq "S")
            }
            4 { 
                Write-Host "Saliendo..." -ForegroundColor Green
            }
            Default {
                Write-Host "Opción no válida" -ForegroundColor Red
            }
        }
    }While($opc -ne 4)
}