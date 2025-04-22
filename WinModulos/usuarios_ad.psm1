import-Module ..\WinModulos\validadores.psm1

function crear_user_ad{
    Write-Host "---Seccion de creacion de usuarios---"

    do{
        $user = Read-Host "Ingresa el nombre del usuario"
        Write-Host $user
        if((validar_textos_nulos -texto $user) -eq $false){
            Write-Host "El nombre de usuario no puede estar vacio" -ForegroundColor Red
            $v1=$false
            continue
        }
        if((validar_espacios -usuario $user) -eq $false){
            Write-Host "El nombre de usuario no puede contener espacios" -ForegroundColor Red
            $v2=$false
            continue
        }
    }while($v1 -eq $false -or $v2 -eq $false)


    $password = Read-Host "Ingresa la contraseña del usuario" -AsSecureString

    #Menu de seleccion de OU
    do{
        Write-Host "Selecciona la OU donde se creara el usuario"
        Write-Host "1. OU cuates"
        Write-Host "2. OU no cuates"
        $opcou = Read-Host "Ingresa la OU <1/2>"
        switch($opcou){
            1{
                $ou = "cuates"
                Write-Host "Seleccionaste la OU cuates"
            }
            2{
                $ou = "no cuates"
                Write-Host "Seleccionaste la OU no cuates"
            }
            default{
                Write-Host "Opcion no valida, selecciona una opcion valida" -ForegroundColor Red
            }
        }

    $ouPath = "OU=$ou,DC=cuates,DC=local"
    }while($opcou -ne 1 -and $opcou -ne 2)
    
    try{
        New-ADUser -Name $user -SamAccountName $user -AccountPassword $password -Enabled $true -Path $ouPath
        Write-Host "Usuario $user creado exitosamente en la OU $ou" -ForegroundColor Green
    }catch{
        Write-Host "Error al crear el usuario: $_" -ForegroundColor Red
    }
}
function eliminar_user_ad{
    Write-Host "---Seccion de eliminacion de usuarios---"

    do{
        $user = Read-Host "Ingresa el nombre del usuario"
        Write-Host $user
        if((validar_textos_nulos -texto $user) -eq $false){
            Write-Host "El nombre de usuario no puede estar vacio" -ForegroundColor Red
            $v1=$false
            continue
        }
        if((validar_espacios -usuario $user) -eq $false){
            Write-Host "El nombre de usuario no puede contener espacios" -ForegroundColor Red
            $v2=$false
            continue
        }
    }while($v1 -eq $false -or $v2 -eq $false)

    try{
        Remove-ADUser -Identity $user -Confirm:$false
        Write-Host "Usuario $user eliminado exitosamente" -ForegroundColor Green
    }catch{
        Write-Host "Error al eliminar el usuario: $_" -ForegroundColor Red
    }
}
