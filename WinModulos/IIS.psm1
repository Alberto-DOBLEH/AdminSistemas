function IIS(){
    #Obtenecion del modulo de IIS
    Write-Host "Verificar si estan los modulos de IIS"
    Get-WindowsFeature -Name *IIS*

    #Instalacion del Web Server que utilizaremos en IIS
    Write-Host "Instalando el servicio de Web Server para poder generar la pagina.."
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools

    #Creacion de las carpeta de contencion del sitio
    # Asignacion de paths
    $httpPath = "C:\HTTP"
    $pagePath = "$httpPath\Pagina"
    # Creacion de carpetas con comandos
    Write-Host "Creando las carpetas..."
    try{
        Write-Host "Creando la carpeta raiz del HTTP...."
        New-Item -ItemType Directory -Name "HTTP" -Path $httpPath
        Write-Host "Creando la carpeta de la Pagina...."
        New-Item -ItemType Directory -Name "Pagina" -Path $pagePath
    }catch{
        Write-Host "[Error]. Error inesperado al crear las carpetas" -ForegroundColor Red
    }
    #Creacion del archivo Index de la pagina 
    Write-Host "Creando el archivo index en la carpeta de la pagina..."
    New-Item -ItemType File -Name "index.html" -Path "$pagePath\"

    $port = Read-Host "Que puerto desea usar? "

    #Ceacion del IIS Site
    Write-Host "Creando el IIS Site para generar la pagina, usando el puerto recibido..."
    New-IISSite -Name "Pagina" -PhysicalPath "$pagePath\" -BindingInformation "*:$($port):"

    #Regla de Firewall
    Write-Host "Creando regla de firewall para el servicio HTTP.."
    New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow


    #Agregar el formato de HTML dentro del archivo
    # Definir la ruta donde se guardará el archivo
    $ruta = "$pagePath\index.html"

    # Definir el contenido HTML como una cadena
    $contenidoHTML = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Curriculum</title>
    <style>
        body {
            font-family: 'Times New Roman', Times, serif;
        }
    </style>
</head>
<body>
    <h1> Curriculum Vitae</h1>
    <label><strong>Nombre: </strong> Hernandez Hernandez Luis Alberto </label><br><br>
    <label><strong>Edad: </strong> 20 años</label><br><br>
    <label><strong>Telefono: </strong>6681348867</label><br><br>
    <label><strong>Correo: </strong>luis.alberto.hdez.hdez245@gmail.com</label><br><br>
    <label><strong>Domicilio: </strong>H.Galeana 1918 Alamos Country Los Mochis Sinaloa Mexico</label><br><br>
    <label><b>Estudios:</b></label><br><br>
    <ul>
        <li><b>Primaria: </b>Primaria Profesor Santiago Zuñiga Barron</li>
        <li><b>Secundaria: </b>Escuela Secundaria General No.4 "Jose Maria Martinez Rodriguez"</li>
        <li><b>Preparatoria: </b>Unidad Academica Preparatoria Los Mochis</li>
        <li><b>Universidad: </b>Universidad Autonoma de Sinaloa</li>
    </ul>
    <label><b>Hobbies:</b></label>
    <ul>
        <li>Videojuegos</li>
        <li>Gimnasio</li>
        <li>Correr</li>
        <li>Leer</li>
        <li>Ver Series</li>
    </ul>
    <label><b>Gustos:</b></label>
    <ul>
        <li>Pozole</li>
        <li>Gueritas Mamonas</li>
        <li>Culos</li>
        <li>Cafe</li>
        <li>Chilaquiles</li>
    </ul>

</body>
</html>
"@

    # Escribir el contenido en el archivo (crea o sobrescribe)
    Set-Content -Path $ruta -Value $contenidoHTML -Encoding UTF8

    #Iniciar el servidor
    Start-IISSite -Name "Pagina"

    #Verificar que este corriendo la pagina
    Get-IISSite -Name "Pagina"
}