Import-Module ../WinModulos/validadores.psm1

#Instalacion de servicios para FTP
Install-WindowsFeature Web-FTP-Server -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature Web-Basic-Auth 
Import-Module WebAdministration


#Creacion carpeta raiz
$ftpPath = "C:\FTP"
New-Item -Path $ftpPath -ItemType Directory
#Creacion del Site
New-webSite -Name "FTP" -Port 21 -PhysicalPath $ftpPath

#Creacion de grupo para FTP
$FTPUserGroupName = "Usuarios de FTP"
$ADSI = [ADSI]"WinNT://$env:ComputerName"
$FTPUserGroup = $ADSI.Create("Group", "$FTPUserGroupName")
$FTPUserGroup.SetInfo()
$FTPUserGroup.Description = "Los miembros de este grupo pueden conectar al FTP"
$FTPUserGroup.SetInfo()

#Creacion de usuarios
$FTPUserName = "alberto"
$FTPPassword = "Hola9080"
$CreateUserFTPUser = $ADSI.Create("User", "$FTPUserName")
$CreateUserFTPUser.SetInfo()
$CreateUserFTPUser.SetPassword("$FTPPassword")
$CreateUserFTPUser.SetInfo()

#Añadir usuario al grupo
$UserAccount = New-Object System.Security.Principal.NTAccount("$FTPUserName")
$SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
$Group = [ADSI]"WinNT://$env:ComputerName/$FTPUserGroupName,Group"
$User = [ADSI]"WinNT://$SID"
$Group.Add($User.Path)

#Habilitar autenticacion basica
$FTPSitePath = "IIS:\Sites\$FTPSiteName"
$BasicAuth = "ftpServer.security.authentication.basicAuthentication.enabled"
Set-ItemProperty -Path $FTPSitePath -Name $BasicAuth -Value $True
$Param = @{
    Filter = "/system.ftpServer/security/authorization"
    Value = @{
        accessType = "Allow"
        roles = "$FTPUserGroupName"
        permissions = 1
    }
    PSPath = "IIS:\"
    Location = $FTPSiteName
}
Add-WebConfiguration @param

$SSLPolicy = @(
    "ftpServer.security.ssl.controlChannelPolicy",
    "ftpServer.security.ssl.dataChannelPolicy"

)
Set-ItemProperty -Path $FTPSitePath -Name $SSLPolicy[0] -Value $false
Set-ItemProperty -Path $FTPSitePath -Name $SSLPolicy[1] -Value $false

$UserAccount = New-Object System.Security.Principal.NTAccount("$FTPUserGroupName")
$AccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($UserAccount,
    "ReadAndExecute",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

$ACL = Get-Acl -Path $ftpPath
$ACL.SetAccessRule($AccessRule)
$ACL | Set-Acl -Path $ftpPath

Restart-WebItem "IIS:\Sites\FTP" -Verbose