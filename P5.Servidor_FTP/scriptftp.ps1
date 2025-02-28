#Instalacion de los servcios para el servidor FTP
Install-WindowsFeature Web-FTP-Server -IncludeManagementTools
Install-WindowsFeature Web-Server -IncludeManagementTools
Import-Module WebAdministration

#Creacion de carpeta de FTP
$ftpPath = "C:\FTP"
New-Item -Path $ftpPath -ItemType Directory
$rootPath = "C:\FTP\root"
New-Item -Path $rootPath -ItemType Directory

#Creacion de un sitio FTP
New-webSite -Name "FTP" -Port 45 -PhysicalPath $rootPath -Server localhost

#Creacion de grupos de usuarios para FTP
$ADSI = [ADSI]"WinNT://$env:ComputerName"

#Creacion de grupo de reprobados para FTP
$FTPUserGroupName1 = "reprobados"
$FTPUserGroup1 = $ADSI.Create("Group", "$FTPUserGroupName1")
$FTPUserGroup1.SetInfo()
$FTPUserGroup1.Description = "Miembros reprobados"
$FTPUserGroup1.SetInfo()

#Creacion de grupo de recursadores para FTP
$FTPUserGroupName2 = "recursadores"
$FTPUserGroup2 = $ADSI.Create("Group", "$FTPUserGroupName2")
$FTPUserGroup2.SetInfo()
$FTPUserGroup2.Description = "Miembros recursadores"
$FTPUserGroup2.SetInfo()

$FTPUserName = Read-Host "Ingrese el nombre de usuario para FTP"
$FTPPassword = Read-Host -AsSecureString "Ingrese la contraseña para FTP"
$CreateUserFTPUser = $ADSI.Create("User", "$FTPUserName")
$CreateUserFTPUser.SetInfo()
$CreateUserFTPUser.SetPassword("$FTPPassword")
$CreateUserFTPUser.SetInfo()


