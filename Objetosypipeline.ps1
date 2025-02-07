#Ilustracion50
Get-Service -Name "LSM" | Get-Member

#Ilustracion51
Get-Service -Name "LSM" | Get-Member -MemberType Property

#Ilustracion52
Get-Item .\test.txt |Get-Member -MemberType Method

#Ilustracion53
Get-Item .\test.txt | Select-Object Name, length

#Ilustracion54
Get-Service | Select-Object -Last 5

#Ilustracion55
Get-Service | Select-Object -First 5

#Ilustracion56
Get-Service | Where-Object {$_.Status -eq "Running"}

#Ilustracion57
(Get-Item.\test.txt).IsReadOnly
(Get-Item.\test.txt).IsReadOnly = 1
(Get-Item.\test.txt).IsReadOnly

#Ilustracion58
Get-ChildItem *.txt

#Ilustracion59
$miObjeto = new-object PSObject
$miObjeto | add-member -MemberType NoteProperty -Name Nombre -Value "Miguel"
$miObjeto | add-member -MemberType NoteProperty -Name Edad -Value 23
$miObjeto | add-member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "Hola Mundo "}

#Ilustracion60
$miObjeto = new-Object -TypeName PSObject -Property @{
        Nombre = "Miguel"
        Edad = 23
}
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value {Write-Host "Hola Mundo"}
$miObjeto | Get-Member 

#Ilustracion61
$miObjeto = new-Object = [PSCustomObject] @{
    Nombre = "Miguel"
    Edad = 23
}
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value {Write-Host "Hola Mundo"}
$miObjeto | Get-Member

#Ilustracion62
Get-Process -Name Acrobat | Stop-Process

#Ilustracion63
Get-Help -Full Stop-Process

#Ilustracion64
Get-Help -Full Get-Process

#Ilustracion65
Get-Process
Get-Process -Name Acrobat | Stop-Process
Get-Process0

#Ilustracion66
Get-Help -Full Get-ChildItem
Get-Help -Full Get-Clipboard
Get-ChildItem *.txt | Get-Clipboard

#Ilustracion67
Get-Help -Full Stop-Service

#Ilustracion69
Get-Service
Get-Service Spooler | Stop-Service
Get-Service

#Ilustracion70
Get-Service
"Spooler" | Stop-Service
Get-Service

#Ilustracion71
Get-Service
$miObjeto = [PSCustomObject]@{
    Name = "Spooler"
}
$miObjeto | Stop-Service
Get-Service
