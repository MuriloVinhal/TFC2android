# Quick Test Implementation Status Check
Write-Host "🔍 PetTime Test Status Verification" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Count test files
$frontendTests = Get-ChildItem "pettime_frontend\test" -Recurse -Filter "*test.dart" -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
$backendTests = Get-ChildItem "pettime-backend\tests" -Recurse -Filter "*.test.js" -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "`n📊 Test Implementation Summary" -ForegroundColor Yellow
Write-Host "  📱 Frontend Test Files: $frontendTests" -ForegroundColor Green
Write-Host "  🖥️ Backend Test Files: $backendTests" -ForegroundColor Green
Write-Host "  📋 Total Test Files: $($frontendTests + $backendTests)" -ForegroundColor Cyan

# Check critical files
$criticalFiles = @(
    "TESTING.md",
    "RELATORIO-TESTES-TFC.md",
    "run-tests.ps1",
    "run-coverage.ps1",
    "run-tests-enhanced.ps1",
    "pettime_frontend\pubspec.yaml",
    "pettime-backend\jest.config.json",
    "pettime-backend\package.json"
)

Write-Host "`n📁 Critical Files Check" -ForegroundColor Yellow
$allCriticalExist = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file" -ForegroundColor Red
        $allCriticalExist = $false
    }
}

# Check key test directories
Write-Host "`n📂 Test Structure Check" -ForegroundColor Yellow
$testDirs = @(
    "pettime_frontend\test\modules\auth",
    "pettime_frontend\test\modules\home",
    "pettime_frontend\test\shared",
    "pettime-backend\tests\controllers",
    "pettime-backend\tests\services",
    "pettime-backend\tests\integration"
)

foreach ($dir in $testDirs) {
    if (Test-Path $dir) {
        $count = Get-ChildItem $dir -Filter "*test.*" | Measure-Object | Select-Object -ExpandProperty Count
        Write-Host "  ✅ $dir ($count files)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $dir" -ForegroundColor Red
    }
}

# Final status
Write-Host "`n🎯 Implementation Status" -ForegroundColor Yellow
if ($frontendTests -gt 0 -and $backendTests -gt 0 -and $allCriticalExist) {
    Write-Host "✅ COMPLETE - Test suite ready for execution!" -ForegroundColor Green
    Write-Host "`n🚀 Ready to run:" -ForegroundColor Cyan
    Write-Host "   .\run-tests-enhanced.ps1 -TestType all" -ForegroundColor White
    Write-Host "   .\run-tests-enhanced.ps1 -TestType all -Coverage" -ForegroundColor White
} else {
    Write-Host "⚠️ INCOMPLETE - Some components missing" -ForegroundColor Yellow
}

Write-Host "`n📖 Documentation:" -ForegroundColor Cyan
Write-Host "   TESTING.md - Technical guide" -ForegroundColor White
Write-Host "   RELATORIO-TESTES-TFC.md - TFC report" -ForegroundColor White