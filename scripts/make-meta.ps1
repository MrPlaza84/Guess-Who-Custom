# Script para generar metadata JSON de character sets (equivalente a make-meta.sh para PowerShell)

$CHARSET_META_FILENAME = "charset-meta.json"
$CHAR_META_FILENAME = "char-meta.json"
$CONFIG_FILENAME = "config.json"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $ROOT_DIR  # Go up one more level
$CHARSET_DIR = Join-Path (Join-Path $ROOT_DIR "public") "character-sets"

Set-Location $CHARSET_DIR

# Empezar a crear el archivo de metadata de character sets
$charsetMetaContent = '{"sets":['

# Obtener lista de directorios
$directories = Get-ChildItem -Directory | Sort-Object Name
$firstDir = $true

foreach ($dir in $directories) {
    # Agregar coma para separar del anterior
    if (-not $firstDir) {
        $charsetMetaContent += ','
    } else {
        $firstDir = $false
    }
    
    $charsetMetaContent += '"' + $dir.Name + '"'
    
    # Crear archivo de metadata de characters para esta carpeta
    $dirPath = $dir.FullName
    Push-Location $dirPath
    
    $charMetaContent = '{"chars":['
    
    $files = Get-ChildItem -Filter "*.png" | Sort-Object Name
    $firstFile = $true
    
    foreach ($file in $files) {
        # Agregar coma para separar del anterior
        if (-not $firstFile) {
            $charMetaContent += ','
        } else {
            $firstFile = $false
        }
        
        $charMetaContent += '"' + $file.Name + '"'
    }
    
    $charMetaContent += ']'
    
    # Incluir config si existe
    if (Test-Path $CONFIG_FILENAME) {
        $configContent = Get-Content $CONFIG_FILENAME -Raw
        $charMetaContent += ',"config":' + $configContent
    } else {
        $charMetaContent += ',"config":null'
    }
    
    $charMetaContent += '}'
    
    # Escribir archivo char-meta.json
    Set-Content -Path $CHAR_META_FILENAME -Value $charMetaContent
    Write-Host "Creado: $($dir.Name)/$CHAR_META_FILENAME"
    
    Pop-Location
}

$charsetMetaContent += ']}'

# Escribir archivo charset-meta.json en la carpeta de character-sets
Set-Location $CHARSET_DIR
Set-Content -Path $CHARSET_META_FILENAME -Value $charsetMetaContent
Write-Host "Creado: $CHARSET_META_FILENAME"

Write-Host "Archivos de metadata generados exitosamente!"
