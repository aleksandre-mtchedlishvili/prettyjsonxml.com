# =====================================================================
# build-deploy.ps1 -- assemble the deploy/ folder for Cloudflare Pages
#
# Usage:  .\build-deploy.ps1
#         (or right-click -> Run with PowerShell)
#
# What it does:
#   1. Wipes any previous deploy/ folder
#   2. Recreates the folder structure (deploy/, deploy/guide/, deploy/example/)
#   3. Copies the runtime files into it
#   4. Prints a summary table so you can sanity-check before uploading
#
# After this finishes, drag the deploy/ folder into Cloudflare Pages.
# DO NOT zip it -- PowerShell's Compress-Archive writes backslash paths
# that Cloudflare's Linux extractor mangles. Folder upload is reliable.
# =====================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Pin all paths to the script's own folder so it works regardless of
# where it's invoked from (PS prompt, double-click, scheduled task, etc.)
$ScriptRoot = $PSScriptRoot
if (-not $ScriptRoot) { $ScriptRoot = (Get-Location).Path }
Set-Location $ScriptRoot

Write-Host ""
Write-Host "Building deploy/ from $ScriptRoot" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor DarkGray

# -------- 1. Sanity-check that source files exist before doing anything

$rootFiles = @(
  'index.html',
  'privacy.html',
  'terms.html',
  '_headers',
  'robots.txt',
  'sitemap.xml',
  'og.jpg'
)
$nestedFiles = @(
  'guide/view-json-as-table.html',
  'example/rss-feed.html'
)
$missing = @()
foreach ($f in ($rootFiles + $nestedFiles)) {
  if (-not (Test-Path $f)) { $missing += $f }
}
if ($missing.Count -gt 0) {
  Write-Host ""
  Write-Host "ERROR -- missing source files:" -ForegroundColor Red
  $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  Write-Host ""
  Write-Host "Run this script from the project root (where index.html lives)." -ForegroundColor Yellow
  exit 1
}

# -------- 2. Wipe + recreate deploy/

if (Test-Path deploy) {
  Remove-Item -Recurse -Force deploy
  Write-Host "  cleaned old deploy/" -ForegroundColor DarkGray
}
New-Item -ItemType Directory -Path deploy         | Out-Null
New-Item -ItemType Directory -Path deploy/guide   | Out-Null
New-Item -ItemType Directory -Path deploy/example | Out-Null
Write-Host "  created deploy/, deploy/guide/, deploy/example/" -ForegroundColor DarkGray

# -------- 3. Copy

foreach ($f in $rootFiles) {
  Copy-Item $f -Destination "deploy/$f"
}
Copy-Item 'guide/view-json-as-table.html'     -Destination 'deploy/guide/view-json-as-table.html'
Copy-Item 'example/rss-feed.html'             -Destination 'deploy/example/rss-feed.html'

# -------- 4. Summarize

Write-Host ""
Write-Host "Deploy folder contents:" -ForegroundColor Green
$total = 0
$count = 0
Get-ChildItem -Recurse deploy -File | ForEach-Object {
  $rel = $_.FullName.Substring((Resolve-Path deploy).Path.Length + 1)
  $kb  = [math]::Round($_.Length / 1KB, 1)
  $total += $_.Length
  $count += 1
  '{0,8} KB  {1}' -f $kb, ($rel -replace '\\','/')
}
Write-Host ""
Write-Host ("  Total: {0} KB across {1} files" -f `
  [math]::Round($total / 1KB, 1), $count) -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: open Cloudflare Pages dashboard, choose Direct upload," -ForegroundColor Yellow
Write-Host "      and drag the deploy/ folder itself (NOT a zip of it)." -ForegroundColor Yellow
Write-Host ""
