#Ilustracion93
try{
    Write-Output "Todo Bien"
}catch{
    Write-Output "Algo lanzo una excepcion"
    Write-Output $_
}

try{
    Start-Something -ErrorAction Stop
}catch{
    Write-Output "Algo genero una excepcion o uso Write-Error"
    Write-Output $_
}

#Ilustracion94
$comando = [System.Data.SqlClient.SqlCommand]::New(queryString, connection)
try{
    $comando.Connection.Open()
    $comando.ExecuteNonQuery()
}finally{
    Write-Error "Ha habido un problema con la ejecucion de la query. Cerrando la conexion"
    $comando.Connection.Close()
}

#Ilustracion95
try{
    Start-Something -Path $path -ErrorAction Stop
}catch [System.IO.DirectoryNotFoundException], [System.IO.FileNotFoundException]
{
    Write-Output "El directorio o fichero no ha sido encontrado: [$path]"
}
catch[System.IO.IOException]
{
    Write-Output "Error de IO con el archivo: [$path]"
}

#Ilustracion96
throw "No se puede encontrar la ruta: [$path]"

throw [System.IO.FileNotFoundException] "No se puede encontrar la ruta: [$path]"

throw [System.IO.FileNotFoundException]::new()

throw [System.IO.FileNotFoundException]::new("No se puede encontrar la ruta: [$path]")

throw (New-Object -TypeName System.IO.FileNotFoundException )

throw (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "No se puede encontrar la ruta: [$path]")

#Ilustracion97
trap{
    Write-Output $PSItem.toString()
}
throw [System.Exception]::new('primero')
throw [System.Exception]::new('segundo')
throw [System.Exception]::new('tercero')

#Ilustracion102
ls
Import-Module BackupRegistry

#Ilustracion103
Get-Help Backup-Registry

#Ilustracion104
Backup-Registry -rutaBackup 'C:\Users\djmin\Desktop'

#Ilustracion105
