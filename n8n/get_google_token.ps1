# Script para generar el token de Google para n8n
# Ejecutar con: powershell -ExecutionPolicy Bypass -File n8n/get_google_token.ps1

$keyFile = Join-Path $PSScriptRoot '..\brawl-tcg-database-firebase-adminsdk-fbsvc-870d49525b.json'

if (-not (Test-Path $keyFile)) {
    Write-Host "ERROR: No se encuentra el archivo JSON." -ForegroundColor Red
    Write-Host "Ruta buscada: $keyFile" -ForegroundColor Red
    exit 1
}

$sa            = Get-Content $keyFile | ConvertFrom-Json
$clientEmail   = $sa.client_email
$privateKeyPem = $sa.private_key

# Limpiar PEM
$privateKeyBase64 = $privateKeyPem `
    -replace '-----BEGIN PRIVATE KEY-----', '' `
    -replace '-----END PRIVATE KEY-----', '' `
    -replace '\\n', '' `
    -replace "`n", '' `
    -replace "`r", '' `
    -replace ' ',  ''

$privateKeyBytes = [Convert]::FromBase64String($privateKeyBase64)

# Cargar clave RSA via X509 (compatible con PowerShell 5.1 / .NET Framework)
Add-Type -AssemblyName System.Security

# Parsear PKCS8 manualmente: saltar los primeros 26 bytes de cabecera PKCS8
# y usar el RSA key interno en formato PKCS1
$rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
try {
    # Intentar con CngKey (disponible en .NET 4.6+)
    $cngKey = [System.Security.Cryptography.CngKey]::Import(
        $privateKeyBytes,
        [System.Security.Cryptography.CngKeyBlobFormat]::Pkcs8PrivateBlob
    )
    $rsa = [System.Security.Cryptography.RSACng]::new($cngKey)
} catch {
    Write-Host "ERROR cargando la clave RSA: $_" -ForegroundColor Red
    exit 1
}

# Base64Url encode
function Base64UrlEncode($bytes) {
    return [Convert]::ToBase64String($bytes) `
        -replace '\+', '-' `
        -replace '/', '_' `
        -replace '=+$', ''
}

# JWT Header
$header    = '{"alg":"RS256","typ":"JWT"}'
$headerEnc = Base64UrlEncode([System.Text.Encoding]::UTF8.GetBytes($header))

# JWT Payload
$now    = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$exp    = $now + 3600
$scope  = 'https://www.googleapis.com/auth/cloud-platform'
$aud    = 'https://oauth2.googleapis.com/token'
$payload    = "{`"iss`":`"$clientEmail`",`"scope`":`"$scope`",`"aud`":`"$aud`",`"exp`":$exp,`"iat`":$now}"
$payloadEnc = Base64UrlEncode([System.Text.Encoding]::UTF8.GetBytes($payload))

# Firmar con RS256
$signingInput = "$headerEnc.$payloadEnc"
$signingBytes = [System.Text.Encoding]::UTF8.GetBytes($signingInput)
$signature    = $rsa.SignData(
    $signingBytes,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
)
$signatureEnc = Base64UrlEncode($signature)
$jwt = "$headerEnc.$payloadEnc.$signatureEnc"

# Intercambiar JWT por access token
$body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=$jwt"
try {
    $response = Invoke-RestMethod -Method POST `
        -Uri 'https://oauth2.googleapis.com/token' `
        -ContentType 'application/x-www-form-urlencoded' `
        -Body $body
} catch {
    Write-Host "ERROR obteniendo token: $_" -ForegroundColor Red
    exit 1
}

$token = $response.access_token

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " TOKEN GENERADO (valido 1 hora)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Bearer $token" -ForegroundColor Yellow
Write-Host ""
Write-Host "Copia la linea amarilla y pegala en" -ForegroundColor Cyan
Write-Host "el campo Value de 'Firestore Auth' en n8n." -ForegroundColor Cyan
Write-Host ""
