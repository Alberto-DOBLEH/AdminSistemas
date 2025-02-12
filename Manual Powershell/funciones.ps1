#Ilustracion73
get-verb

#Ilustracion74
function Get-Fecha{
    Get-Date
}
Get-Fecha

#Ilustracion75
Get-ChildItem -Path Function:\Get-*

#Ilustracion76
Get-ChildItem -Path Function:\Get-Fecha | Remove-Item
Get-ChildItem -Path Function:\Get-*

#Ilustracion77
function Get-Resta {
    Param ([int]$num1, [int]$num2 )
    $resta = $num1-$num2
    Write-Host "La resta de los parametros es $resta"
}

#Ilustracion78
Get-Resta 10 5

#Ilustracion79
Get-Resta -num2 10 -num1 5 

#Ilustracion80
Get-Resta -num2 10

#Ilustracion81
function Get-Resta {
    Param ([Parameter(Mandatory)][int]$num1, [int]$num2 )
    $resta = $num1-$num2
    Write-Host "La resta de los parametros es $resta"
}
Get-resta -num2 10

#Ilustracion82
function get-resta {
    [cmdletBinding()]
    param ([Int]$num1, [Int]$num2)
    $resta=$num1-$num2
    Write-Host "La resta de los parametros es $resta"
}

#Ilustracion83
(Get-Command -name get-resta).Parameters.Keys

#Ilustracion84
function Get-Resta {
    [cmdletBinding()]
    Param ([int]$num1, [int]$num2)
    $resta=$num1-$num2
    Write-Host "La reta de los parametros es $resta"
}

#Ilustracion85
function Get-Resta {
    [cmdletBinding()]
    Param ([int]$num1, [int]$num2)
    $resta=$num1-$num2
    Write-Verbose -Message "Operacion que va realizar una resta de $num1 y $num2"
    Write-Host "La reta de los parametros es $resta"
}
Get-Resta 10 5 -Verbose