function crear_user_ad{
    Write-Host "---Seccion de creacion de usuarios---"

    $user = Read-Host "Ingresa el nombre del usuario"

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
function Modificar_user_ad{

}
function Eliminar_user_ad{

}
