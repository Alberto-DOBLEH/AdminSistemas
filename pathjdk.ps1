[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-21", [System.EnvironmentVariableTarget]::Machine)

$jdkBinPath = "C:\Program Files\Java\jdk-21\bin"
$existingPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($existingPath -notlike "*$jdkBinPath*") {
    $newPath = "$existingPath;$jdkBinPath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
}

echo $env:JAVA_HOME
echo $env:Path
