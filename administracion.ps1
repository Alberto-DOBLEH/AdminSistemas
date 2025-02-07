#Ilustracion 111
Get-Service

#Ilustracion 112
Get-Service -Name Spooler
Get-Service -DisplayName Hora*

#Ilustracion 113
Get-Service | Where-object {$_.Status -eq "Running"}

#Ilustracion114
Get-Service |
Where-Object {$_.StartType -eq "Automatic"} |
Select-Object Name, StartType

#Ilustracion115
Get-Service -DependentServices Spooler

#Ilustracion116
Get-Service -RequiredServices Fax

#Ilustracion117
Stop-Service -Name Spooler -Confirm -PassThru

#Ilustracion118
Start-Service -Name Spooler -Confirm -PassThru

#Ilustracion119
Suspend-Service -Name stisvc -Confirm -PassThru

#Ilustracion120
Get-Sercice | Where-Object CanPauseAndContinue -eq True

#Ilustracion121
Suspend-Service -Name Spooler

#Ilustracion122
Restart-Service -Name WSearch -Confirm -PassThru

#Ilustracion123
Set-Service -Name dcsvc -DisplayName "Servicio de virtualizacion de credenciales de seguridad distribuidas"

#Ilustracion124
Set-Service -Name BITS -StartupType Automatic -Confirm -PassThru | Select-Object Name, StartType

#Ilustracion125
Set-Service -Name BITS -Description "Transfiere archivos en segundo plano mediante el uso de ancho de banda de red inactivo"

#Ilustracion126
Get-CimInstance Win32_Service -Filter 'Name = "BITS"' | Format-List Name,Description

#Ilustracion127
Set-Service -Name Spooler -Status Running -Confirm -PassThru

#Ilustracion129
Set-Service -Name stisvc -Status Paused -Confirm -PassThru

#Ilustracion128
Set-Service -Name BITS -Status Stopped -Confirm -PassThru

#Ilustracion130
Get-Process

#Ilustracion131
Get-Process -Name Acrobat
Get-Process -Name Search*
Get-Process -Id 13948

#Ilustracion132
Get-Process WINWORD -FileVersionInfo

#Ilustracion133
Get-Process WINWORD -IncludeUserName

#Ilustracion134
Get-Process WINWORD -Module

#Ilustracion135
Stop-Process -Name Acrobat -Confirm -PassThru
Stop-Process -Id 10940 -Confirm -PassThru
Get-Process -Name Acrobat | Stop-Process -Confirm -PassThru

#Ilustracion136
Start-Process -FilePath "C:\Windows\System32\notepad.exe" -PassThru

#Ilustracion137
Start-Process -FilePath "cmd.exe" -ArgumentList "/c mkdir NUEVACARPETA" -WorkingDirectory "C:\Users\djmin\Documents" -PassThru

#Ilustracion138
Start-Process -FilePath "notepad.exe" -WindowStyle "Maximized" -PassThru

#Ilustracion139
Start-Process -FilePath "C:\Users\djmin\Desktop\Instalación y configuración de distro Linux y Windows Server.pdf" -Verb Print -PassThru

#Ilustracion140
Get-Process -Name notep*
Wait-Process -Name notepad
Get-Process -Name notep*
Get-Process -Name notepad
Wait-Process -Id 11568
Get-Process -Name notep*
Get-Process -Name notep*
Get-Process -Name notepad | Wait-Process

#Ilustracion141
Get-LocalUser

#Ilustracion142
Get-LocalUser -Name Miguel | Select-Object *

#Ilustracion143
Get-LocalUser -SID S-1-5-21-619924196-4045554399-1956444398-500 | Select-Object *

#Ilustracion144
Get-LocalGroup

#Ilustracion145
Get-LocalGroup -Name Administradores | Select-Object *

#Ilustracion146
Get-LocalGroup -SID S-1-5-32-545 | Select-Object *

#Ilustracion147
New-LocalUser -Name "Usuario2" -Description "Usuario de prueba 2" -Password (ConvertTo-SecureString -AsPlainText "12345" -Force)|

#Ilustracion148
New-LocalUser -Name "Usuario1" -Description "Usuario de prueba 1" -NoPassword

#Ilustracion149
Get-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario2"

#Ilustracion150
New-LocalGroup -Name 'Grupo1' -Description 'Grupo de prueba 1'

#Ilustracion151
Add-LocalGroupMember -Group Grupo1 -Member Usuario2 -Verbose

#Ilustracion152
Get-LocalGroupMember

#Ilustracion153
Remove-LocalGroupMember -Group Grupo1 -Member Usuario1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario2
Get-LocalGroupMember Grupo1

#Ilustracion154
Get-LocalGroup -Name "Grupo1"
Remove-LocalGroup -Name "Grupo1"
Get-LocalGroup -Name "Grupo1"