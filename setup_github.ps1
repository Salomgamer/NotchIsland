Write-Host "========================================" -ForegroundColor Cyan
Write-Host " NotchIsland - Push to GitHub Actions" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Create a repository at: https://github.com/new" -ForegroundColor White
Write-Host "2. Name it: NotchIsland" -ForegroundColor White
Write-Host ""

$repoUrl = Read-Host "Paste your GitHub Repository URL (e.g. https://github.com/username/NotchIsland.git)"

if (-not [string]::IsNullOrWhiteSpace($repoUrl)) {
    git remote remove origin 2>$null
    git remote add origin $repoUrl
    Write-Host "`nPushing main branch to GitHub..." -ForegroundColor Green
    git push -u origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nSuccessfully pushed!" -ForegroundColor Green
        Write-Host "GitHub Actions has automatically started compiling your .ipa on macOS." -ForegroundColor Cyan
        Write-Host "Go to your repo's 'Actions' tab, wait ~2 mins, and download 'NotchIsland.ipa'." -ForegroundColor Yellow
    } else {
        Write-Host "`nPush failed. Check your GitHub URL or login credentials." -ForegroundColor Red
    }
} else {
    Write-Host "No URL provided." -ForegroundColor Yellow
}
