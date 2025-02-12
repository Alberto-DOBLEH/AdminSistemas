#Ilustracion14
$condicion = $false
if ( $condicion ){
    Write-Output "La condicion es verdadera"
}else{
    Write-Output "La condicion es falsa"
}

#Ilustracion15
$numero = 15

if($numero -ge 3){
    Write-Output "El numero [$numero] es mayor o igual que 3"
}elseif($numero -lt 2){
    Write-Output "El numero [$numero] es menor que 2"
}else{
    Write-Output "El numero [$numero] es igual a 2"
}

#Ilustracion17
$PSVersionTable

#Ilustracion18
$mensaje = (Test-Path $path) ? "Path existe" : "Path no encontrado"

#Ilustracion21
switch (5){
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
}

#Ilustracion22
switch (3){
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    3 {"[$_] es tres de nuevo."}
}

#Ilustracion23
switch (3){
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."; Break}
    4 {"[$_] es cuatro."}
    3 {"[$_] es tres de nuevo."}
}

#Ilustracion24
switch (1, 5){
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    3 {"[$_] es cinco"}
}

#Ilustracion25
switch ("seis"){
    1 {"[$_] es uno."; Break}
    2 {"[$_] es dos."; Break}
    3 {"[$_] es tres."; Break}
    4 {"[$_] es cuatro."; Break}
    5 {"[$_] es cinco."; Break}
    "se*" {"[$_] coincide con se*."}
    Default {
        "No hay conincidencias con [$_]"
    }
}

#Ilustracion26
switch -Wildcard("seis"){
    1 {"[$_] es uno."; Break}
    2 {"[$_] es dos."; Break}
    3 {"[$_] es tres."; Break}
    4 {"[$_] es cuatro."; Break}
    5 {"[$_] es cinco."; Break}
    "se*" {"[$_] coincide con se*."}
    Default {
        "No hay conincidencias con [$_]"
    }
}

#Ilustracion27
$email = 'antonio.yanez@udc.es'
$emai12 = 'antonio.yanez@usc.gal'
$url = 'https://www.dc.fi.udc.es/~afyanez/Docencia/2023'
switch -Regex ($url, $email, $emai12){
    '^\w+\.\w+@(udc|usc|edu)\.es|gal$' {"[$_]es una direccion de correo electronico academica"}
    '^ftp\://.*$' {"[$_] es una direccion ftp" }
    '^(http[s]?)\://.*$' {"[$_] es una direccion web, que utiliza [$($matches[1])]" }
}

#Ilustracion31
for (($i = 0), ($j = 0);$i -lt 5; $i++){
    "`$i:$i"
    "`$j:$j"
}

#Ilustracion32
for (($i = 0), ($j = 0);$i -lt 5; $($i++;$j++)){
    "`$i:$i"
    "`$j:$j"
}

#Ilutracion34
$ssoo = "freebsd", "openbsd", "solaris", "fedora", "ubuntu", "netbsd"
foreach ($so in $ssoo){
    Write-Host $so
}

#Ilustracion35
foreach ($archivo in Get-ChildItem){
    if($archivo.length -ge 10KB){
        Write-Host $archivo -> [($archivo.length)]
    }
}

#Ilustracion37
$num = 0

while ($num -ne 3){
    $num++
    Write-Host $num
}

#Ilustracion38
$num = 0
while ($num -ne 5){

    if ($num -eq 1) { $num = $num = $num + 3; Continue}
    $num++
    Write-Host $num
}

#Ilustracion40
$valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
while ($valor -gt 0)

Write-Host $multiplicacion
#Ilustracion41
$valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
until ($valor -eq 0)

Write-Host $multiplicacion

#Ilustracion42
$num = 10
for($i = 2; $i -lt 10; $i++)
{
    $num = $num+$i
    if ($i -eq 5) {Break}
}

Write-Host $num
Write-Host $i

#Ilustracion43
$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"

switch -Wildcard($cadena, $cadena2){
    "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola, bue*]"}
    "Hola,*" {"[$_] coincide con [Hola,*]"; Break}
    "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}

#Ilustracion44
$num = 10
for($i = 2; $i -lt 10; $i++){
    if($i -eq 5) {Continue}
    $num = $num+$i
}
Write-Host $num
Write-Host $i

#Ilustracion45
$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"

switch -Wildcard($cadena, $cadena2){
    "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola, bue*]"; Continue}
    "Hola,*" {"[$_] coincide con [Hola,*]"}
    "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}