# Simple Localhost HTTP Server for Sanklap Study Point
param (
    [int]$Port = 8080
)

$HostName = "localhost"
$Url = "http://$HostName`:$Port/"
$Folder = $PSScriptRoot

$MimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain; charset=utf-8"
}

$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add($Url)

try {
    $Listener.Start()
    Write-Host "Server running at: $Url" -ForegroundColor Green
    Write-Host "Serving files from: $Folder" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop." -ForegroundColor Yellow

    # Open the browser automatically
    Start-Process $Url

    while ($Listener.IsListening) {
        $Context = $Listener.GetContext()
        $Request = $Context.Request
        $Response = $Context.Response

        $LocalPath = $Request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($LocalPath)) {
            $LocalPath = "index.html"
        }

        # Normalize path
        $FilePath = Join-Path $Folder $LocalPath.Replace('/', [IO.Path]::DirectorySeparatorChar)

        if (Test-Path $FilePath -PathType Leaf) {
            $Ext = [IO.Path]::GetExtension($FilePath).ToLower()
            $ContentType = if ($MimeTypes.ContainsKey($Ext)) { $MimeTypes[$Ext] } else { "application/octet-stream" }
            $Response.ContentType = $ContentType

            $Bytes = [IO.File]::ReadAllBytes($FilePath)
            $Response.ContentLength64 = $Bytes.Length
            $Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
            $Response.StatusCode = 200
        } else {
            $Response.StatusCode = 404
            $NotFoundMsg = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 Not Found</h1><p>File not found: $LocalPath</p>")
            $Response.ContentType = "text/html; charset=utf-8"
            $Response.ContentLength64 = $NotFoundMsg.Length
            $Response.OutputStream.Write($NotFoundMsg, 0, $NotFoundMsg.Length)
        }

        $Response.OutputStream.Close()
    }
}
catch {
    Write-Error $_
}
finally {
    if ($Listener.IsListening) {
        $Listener.Stop()
    }
    $Listener.Close()
}
