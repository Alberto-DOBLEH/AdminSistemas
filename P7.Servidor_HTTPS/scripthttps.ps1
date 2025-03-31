Import-Module ..\WinModulos\IIS.psm1
Import-Module ..\WinModulos\Nginx.psm1
Import-Module ..\WinModulos\Tomcat.psm1


#Verificacion Inicial del servicio FTP 
$serviceName = "FTPSVC"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -ne $service) {
    Write-Host "El servicio FTP ya está instalado."
} else {
    Write-Host "El servicio FTP no está instalado" -ForegroundColor Yellow
    #Instalacion de los servcios para el servidor FTP
    Write-Host "Instalando servicios necesarios para el servidor FTP..." -ForegroundColor Yellow
    Install-WindowsFeature -Name Web-Server, Web-Ftp-Server, Web-Ftp-Service, Web-Ftp-Ext, Web-Scripting-Tools -IncludeManagementTools

    Remove-Website -Name "Default Web Site"
    # Firewall rule
    Write-Host "Creando regla de firewall..." -ForegroundColor Yellow
    New-NetFirewallRule -DisplayName "FTP" -Direction Inbound -LocalPort 21 -Protocol TCP -Action Allow

    #Creacion de los grupos
    Write-Host "Creando grupos necesarios para el servidor FTP..." -ForegroundColor Yellow
    New-LocalGroup -Name "reprobados" -Description "Grupo de reprobados"
    New-LocalGroup -Name "recursadores" -Description "Grupo de recursadores"

    #Creacion de carpeta raiz del FTP
    Write-Host "Creando carpeta principal del FTP..." -ForegroundColor Yellow
    $ftpPath = "C:\FTP"
    New-Item -Path $ftpPath -ItemType Directory

    #Creacion de un sitio FTP
    Write-Host "Creando sitio FTP..." -ForegroundColor Yellow
    New-webSite -Name "FTP" -Port 21 -PhysicalPath $ftpPath
    Write-Host "Ajustando los enlaces del sitio..." -ForegroundColor Yellow
    Set-WebBinding -Name "FTP" -BindingInformation "*:21:" -PropertyName Port -Value 80
    New-WebBinding -Name "FTP" -Protocol "ftp" -IPAddress "*" -Port 21

    #Creacion de la propiedad de aislamiento
    Set-ItemProperty -Path "IIS:\Sites\FTP" -Name "ftpserver.userIsolation.mode" -Value 3

    #Creando carpetas escenciales del FTP
    Write-Host "Creando carpetas de reprobados" -ForegroundColor Yellow
    $reprobadosPath = "C:\FTP\reprobados"
    New-Item -Path $reprobadosPath -ItemType Directory

    Write-Host "Creando carpetas de recursadores" -ForegroundColor Yellow
    $recursadoresPath = "C:\FTP\recursadores"
    New-Item -Path $recursadoresPath -ItemType Directory
    
    Write-Host "Creando carpetas de localusers" -ForegroundColor Yellow
    $localuserPath = "C:\FTP\LocalUser"
    New-Item -Path $localuserPath -ItemType Directory

    Write-Host "Creando carpeta general" -ForegroundColor Yellow
    $generalPath = "C:\FTP\LocalUser\Public"
    New-Item -Path $generalPath -ItemType Directory
    New-Item -Path "$generalPath\General" -ItemType Directory

    #Configuracion de los permisos de las carpetas

    # Permitir acceso total a los grupos en sus carpetas
    Write-Host "Asignando los permisos para el grupo de reprobados....." -ForegroundColor Yellow
    icacls $reprobadosPath /grant "reprobados:(OI)(CI)F" /inheritance:r

    Write-Host "Asignando los permisos para el grupo de recursadores....." -ForegroundColor Yellow
    icacls $recursadoresPath /grant "recursadores:(OI)(CI)F" /inheritance:r

    # Permitir acceso total a los usuarios en la carpeta general
    Write-Host "Asignando los permisos para todos en la carpeta publica....." -ForegroundColor Yellow
    icacls $generalPath /grant "Todos:(OI)(CI)F" /inheritance:r
    icacls $generalPath /grant "IUSR:(OI)(CI)F" /inheritance:r
    icacls "$generalPath\General" /grant "Todos:(OI)(CI)F" /inheritance:r
    icacls "$generalPath\General" /grant "IUSR:(OI)(CI)F" /inheritance:r
    icacls $ftpPath /grant "Todos:(OI)(CI)F" /inheritance:r

    Write-Host "Asignando los permisos para LocalUser..." -ForegroundColor Yellow
    icacls $localuserPath /grant "Todos:(OI)(CI)F" /inheritance:r

    #Ajustando autenticaciones con el set Property
    Write-Host "Ajustando la autenticacion desde ItemProperty............." -ForegroundColor Yellow
    $sitioFTP = "FTP"
    Set-ItemProperty "IIS:\Sites\$sitioFTP" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
    Set-ItemProperty "IIS:\Sites\$sitioFTP" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true

    Write-Host "Ajustando la autenticacion desde WebConfiguration........" -ForegroundColor Yellow
    Add-WebConfigurationProperty -filter "/system.ftpServer/security/authentication/basicAuthentication" -name enabled -value true -PSPath "IIS:\Sites\$sitioFTP"
    Add-WebConfigurationProperty -Filter "/system.ftpServer/security/authentication/anonymousAuthentication" -name enabled -Value true -PSPath "IIS:\Sites\$sitioFTP"

    Write-Host "Ajustando los AccesType de los grupos y todos....." -ForegroundColor Yellow
    $FTPSitePath = "IIS:\Sites\$sitioFTP"
    $BasicAuth = 'ftpServer.security.authentication.basicAuthentication.enabled'
    Set-ItemProperty -Path $FTPSitePath -Name $BasicAuth -Value $true 
    $param =@{
        Filter = "/system.ftpServer/security/authorization"
        value = @{
            accessType = "Allow"
            roles = "recursadores"
            permision = 1
        }
        PSPath = 'IIS:\'
        Location = $sitioFTP
    }
    $param2 =@{
        Filter = "/system.ftpServer/security/authorization"
        value = @{
            accessType = "Allow"
            roles = "reprobados"
            permision = 1
        }
        PSPath = 'IIS:\'
        Location = $sitioFTP
    }
    $param3 =@{
        Filter = "/system.ftpServer/security/authorization"
        value = @{
            accessType = "Allow"
            roles = "*"
            permision = "Read, Write"
        }
        PSPath = 'IIS:\'
        Location = $sitioFTP
    }
    Add-WebConfiguration @param
    Add-WebConfiguration @param2
    Add-WebConfiguration @param3

    $SSLPolicy = @(
        'ftpServer.security.ssl.controlChannelPolicy',
        'ftpServer.security.ssl.dataChannelPolicy'
    )
    Write-Host "Ajustando SSL del sitio FTP...." -ForegroundColor Yellow
    Set-ItemProperty "IIS:\Sites\$sitioFTP" -name $SSLPolicy[0] -value 0
    Set-ItemProperty "IIS:\Sites\$sitioFTP" -name $SSLPolicy[1] -value 0

    # Reiniciar FTP para aplicar cambios
    Write-Host "Reiniciando el servicio de FTP....." -ForegroundColor Yellow
    Restart-Service -Name FTPSVC
    Restart-Service W3SVC
    Restart-WebItem "IIS:\Sites\$sitioFTP" -Verbose

    #Mostrar que esta corriendo el servicio
    Write-Host "Verificando si el servicio esta corriendo...." -ForegroundColor Yellow
    Get-Service -Name FTPSVC

    #Mensaje de finalizacion
    Write-Host "Servidor FTP configurado correctamente" -ForegroundColor Green
}
do{
    Write-Host "Desea que se haga un FTPS?"
    $respuesta = Read-Host "Si(S) o No(N)"
    $respuesta = $respuesta.ToUpper()

    switch($respuesta){
        "S"{
                New-SelfSignedCertificate `
                -DnsName "localhost" `
                -CertStoreLocation "Cert:\LocalMachine\My" `
                -FriendlyName "Certificado Local" `
                -NotAfter (Get-Date).AddYears(5) `
                -KeyUsage DigitalSignature, KeyEncipherment `
                -TextExtension "2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2"
            $cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.FriendlyName -eq "Certificado Local" }

            New-Item -Path "C:\Certificados" -ItemType Directory -Force
            Export-PfxCertificate -Cert $Cert -FilePath "C:\Certificados\mi_certificado.pfx" -Password (ConvertTo-SecureString -String "Alberto2004" -Force -AsPlainText)

            $Thumbprint = ($cert.Thumbprint)
            Set-ItemProperty -Path "IIS:\Sites\FTP" -Name sslCertificateHash -Value $Thumbprint
            Set-ItemProperty -Path "IIS:\Sites\FTP" -Name sslCertificateStoreName -Value "My"

            Set-WebConfigurationProperty -filter "/system.applicationHost/sites/FTP/ftpServer/security/ssl" -name "controlChannelPolicy" -value "SslAllow"
            Set-WebConfigurationProperty -filter "/system.applicationHost/sites/FTP/ftpServer/security/ssl" -name "dataChannelPolicy" -value "SslAllow"

            Write-Host "Reiniciando el servicio de FTP....." -ForegroundColor Yellow
            Restart-Service -Name FTPSVC
            Restart-Service W3SVC
            Restart-WebItem "IIS:\Sites\$sitioFTP" -Verbose
        }
        "N"{
            Write-Host "No se creara el certificado para el FTPS"
        }
        default{
            Write-Host "Opcion no valida, intente de nuevo" -ForegroundColor Red
        }
    }
}while($respuesta -ne "S" -and $respuesta -ne "N")

do{
    Write-Host "Como desea descargar los servicios HTTP?"
    Write-Host "[1]. Descargar desde Navegador"
    Write-Host "[2]. Descargar desde FTP"
    $opcion = Read-Host "Elija su opcion"
    switch($opcion){
        1{
            do{
                Write-Host "----Servidor HTTP-----"
                Write-Host "¿Que servicio desea utilizar?"
                Write-Host "[1].-IIS"
                Write-Host "[2].-Nginx"
                Write-Host "[3].-Tomcat"
                $opc = Read-Host "Ingrese su opcion:" 
            
                switch($opc){
                    1 {
                        Write-Host "Pasando con la seccion de IIS...."
                        IIS
                        do{
                            Write-Host "Desea ponerle SSL al IIS?"
                            $ssl = Read-Host "Si(S) o No(N)"
                            $ssl = $ssl.ToUpper()
                            switch($ssl){
                                "S"{
                                    New-NetFirewallRule -Name "HTTPS" -Action Allow -DisplayName "HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443
                                    New-WebBinding -Name "Pagina" -Protocol "https" -IPAddress "*" -Port 443
                                    $cert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.FriendlyName -eq "Certificado Local" }
                                    $Thumbprint = ($cert.Thumbprint)
                                    Set-ItemProperty -Path "C:\HTTP\Pagina" -Name sslCertificateHash -Value $Thumbprint
                                }
                                "N"{
                                    Write-Host "No se le pondra SSL al IIS"
                                }
                                Default{
                                    Write-Host "Opcion no valida, intente de nuevo" -ForegroundColor Red
                                }
                            }
                        }while($ssl -ne "S" -and $ssl -ne "N")
                    }
                    2{
                        Write-Host "Pasando con la seccion de Nginx...."
                        nginx
                        do{
                        Write-Host "Desea ponerle SSL al Nginx?"
                            $ssl = Read-Host "Si(S) o No(N)"
                            $ssl = $ssl.ToUpper()
                            switch($ssl){
                                "S"{
                                }
                                "N"{
                                    Write-Host "No se le pondra SSL al IIS"
                                }
                                Default{
                                    Write-Host "Opcion no valida, intente de nuevo" -ForegroundColor Red
                                }
                            }
                        }while($ssl -ne "S" -and $ssl -ne "N")
                    }
                    3{
                        Write-Host "Pasando con la seccion de Tomcat...."
                        tomcat
                        do{
                            Write-Host "Desea ponerle SSL al Tomcat?"
                                $ssl = Read-Host "Si(S) o No(N)"
                                $ssl = $ssl.ToUpper()
                                switch($ssl){
                                    "S"{
                                    }
                                    "N"{
                                        Write-Host "No se le pondra SSL al IIS"
                                    }
                                    Default{
                                        Write-Host "Opcion no valida, intente de nuevo" -ForegroundColor Red
                                    }
                                }
                            }while($ssl -ne "S" -and $ssl -ne "N")
                    }
                    Default{
                        Write-Host "Opcion no valida. Favor de ingresar una opcion del 1 al 4"
                    }
                }
            }while($opc -ne 1 -and $opc -ne 2 -and $opc -ne 3)
        }
        2{
            Write-Host "Descargando desde el FTP" -ForegroundColor Green
            $ftpUrl = "ftp://localhost/LocalUser/Public/General/nginx-1.25.2.zip"
            $output = "C:\nginx-1.25.2.zip"
            Invoke-WebRequest -Uri $ftpUrl -OutFile $output
        }
        default{
            Write-Host "Opcion no valida, intente de nuevo" -ForegroundColor Red
        }
    }
}while($opcion -ne 1 -and $opcion -ne 2)

