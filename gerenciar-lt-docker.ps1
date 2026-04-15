param(
    [ValidateSet("up", "down", "restart", "logs", "status", "test", "remove-startup")]
    [string]$Action = "status"
)

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-Compose {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & docker compose @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Get-StartupLinksToRemove {
    $startupPath = [Environment]::GetFolderPath("Startup")
    $shell = New-Object -ComObject WScript.Shell

    foreach ($link in Get-ChildItem -Path $startupPath -Filter "*.lnk" -File) {
        $shortcut = $shell.CreateShortcut($link.FullName)
        if (
            $link.Name -like "*iniciar_oculto*" -or
            $shortcut.TargetPath -like "*iniciar_oculto.vbs" -or
            $shortcut.TargetPath -like "*Eron_language_tool*"
        ) {
            [PSCustomObject]@{
                FullName = $link.FullName
                TargetPath = $shortcut.TargetPath
            }
        }
    }
}

function Get-PublishedPort {
    $portOutput = docker compose port languagetool 8081 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($portOutput)) {
        return 8081
    }

    return [int]($portOutput.Split(":")[-1])
}

Push-Location $ProjectRoot

try {
    switch ($Action) {
        "up" {
            Invoke-Compose -Arguments @("up", "-d", "--build")
        }
        "down" {
            Invoke-Compose -Arguments @("down")
        }
        "restart" {
            Invoke-Compose -Arguments @("down")
            Invoke-Compose -Arguments @("up", "-d", "--build")
        }
        "logs" {
            Invoke-Compose -Arguments @("logs", "-f", "--tail", "200")
        }
        "status" {
            Invoke-Compose -Arguments @("ps")
        }
        "test" {
            $hostPort = Get-PublishedPort
            $response = Invoke-RestMethod -Uri "http://localhost:$hostPort/v2/languages" -Method Get -TimeoutSec 15
            $response | ConvertTo-Json -Depth 6
        }
        "remove-startup" {
            $links = @(Get-StartupLinksToRemove)
            if ($links.Count -eq 0) {
                Write-Host "Nenhum atalho do LanguageTool encontrado no Startup."
                return
            }

            foreach ($link in $links) {
                Remove-Item -LiteralPath $link.FullName -Force
                Write-Host "Removido: $($link.FullName)"
            }
        }
    }
}
finally {
    Pop-Location
}
