# Quick Test Verification Script
# Fast validation of test implementation

Write-Host "🔍 PetTime Test Implementation Verification" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check test files exist
$testFiles = @{
    "Frontend Tests" = @(
        "pettime_frontend\test\app_test.dart",
        "pettime_frontend\test\modules\auth\login_page_test.dart",
        "pettime_frontend\test\modules\auth\register_page_test.dart",
        "pettime_frontend\test\modules\home\home_page_test.dart",
        "pettime_frontend\test\modules\user\profile_page_test.dart",
        "pettime_frontend\test\shared\custom_button_test.dart",
        "pettime_frontend\test\integration\app_integration_test.dart"
    )
    "Backend Tests" = @(
        "pettime-backend\tests\controllers\authController.test.js",
        "pettime-backend\tests\controllers\petController.test.js",
        "pettime-backend\tests\controllers\produtoController.test.js",
        "pettime-backend\tests\controllers\usuarioController.test.js",
        "pettime-backend\tests\services\petService.test.js",
        "pettime-backend\tests\utils\password.test.js",
        "pettime-backend\tests\integration\e2e.test.js"
    )
    "Configuration" = @(
        "pettime-backend\jest.config.json",
        "pettime_frontend\pubspec.yaml",
        "run-tests.ps1",
        "run-coverage.ps1",
        "TESTING.md",
        "RELATORIO-TESTES-TFC.md"
    )
}

$allFilesExist = $true

foreach ($category in $testFiles.Keys) {
    Write-Host "`n📁 $category" -ForegroundColor Yellow
    foreach ($file in $testFiles[$category]) {
        if (Test-Path $file) {
            Write-Host "  ✅ $file" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $file" -ForegroundColor Red
            $allFilesExist = $false
        }
    }
}

# Check dependencies
Write-Host "`n🔧 Dependencies Check" -ForegroundColor Yellow

# Frontend dependencies
if (Test-Path "pettime_frontend\pubspec.yaml") {
    $pubspec = Get-Content "pettime_frontend\pubspec.yaml" -Raw
    $requiredDeps = @("flutter_test", "mockito", "build_runner")
    foreach ($dep in $requiredDeps) {
        if ($pubspec -match $dep) {
            Write-Host "  ✅ Flutter: $dep" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Flutter: $dep missing" -ForegroundColor Red
            $allFilesExist = $false
        }
    }
} else {
    Write-Host "  ❌ pubspec.yaml not found" -ForegroundColor Red
    $allFilesExist = $false
}

# Backend dependencies
if (Test-Path "pettime-backend\package.json") {
    $packageJson = Get-Content "pettime-backend\package.json" -Raw
    $requiredDeps = @("jest", "supertest")
    foreach ($dep in $requiredDeps) {
        if ($packageJson -match $dep) {
            Write-Host "  ✅ Node.js: $dep" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Node.js: $dep missing" -ForegroundColor Red
            $allFilesExist = $false
        }
    }
} else {
    Write-Host "  ❌ package.json not found" -ForegroundColor Red
    $allFilesExist = $false
}

# Test count summary
Write-Host "`n📊 Test Implementation Summary" -ForegroundColor Yellow

$frontendTestCount = (Get-ChildItem "pettime_frontend\test" -Recurse -Filter "*test.dart" | Measure-Object).Count
$backendTestCount = (Get-ChildItem "pettime-backend\tests" -Recurse -Filter "*.test.js" | Measure-Object).Count

Write-Host "  📱 Frontend Test Files: $frontendTestCount" -ForegroundColor Cyan
Write-Host "  🖥️ Backend Test Files: $backendTestCount" -ForegroundColor Cyan
Write-Host "  📋 Total Test Files: $($frontendTestCount + $backendTestCount)" -ForegroundColor Cyan

# Quick syntax check
Write-Host "`n🔍 Quick Syntax Validation" -ForegroundColor Yellow

# Check Flutter test syntax
try {
    Set-Location "pettime_frontend"
    $flutterAnalyze = flutter analyze --no-pub 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Flutter tests: No syntax errors" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Flutter tests: Some issues found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Flutter analyze failed" -ForegroundColor Red
} finally {
    Set-Location ..
}

# Check Node.js test syntax
try {
    Set-Location "pettime-backend"
    if (Test-Path "node_modules") {
        $jestDryRun = npm test -- --dry-run 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Node.js tests: Syntax OK" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Node.js tests: Some issues found" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠️ Node.js: Dependencies not installed" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Jest syntax check failed" -ForegroundColor Red
} finally {
    Set-Location ..
}

# Final status
Write-Host "`n" -NoNewline
if ($allFilesExist) {
    Write-Host "🎉 Test Implementation Status: COMPLETE" -ForegroundColor Green
    Write-Host "✅ All test files and configurations are in place" -ForegroundColor Green
    Write-Host "🚀 Ready to run: .\run-tests-enhanced.ps1 -TestType all -Coverage" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Test Implementation Status: INCOMPLETE" -ForegroundColor Yellow
    Write-Host "❌ Some files are missing or have issues" -ForegroundColor Red
}

Write-Host "`n📖 Documentation Available:" -ForegroundColor Cyan
Write-Host "  • TESTING.md - Technical testing guide" -ForegroundColor White
Write-Host "  • RELATORIO-TESTES-TFC.md - TFC report" -ForegroundColor White
Write-Host "  • run-tests-enhanced.ps1 - Enhanced test automation" -ForegroundColor White

Write-Host "`n🔧 Quick Commands:" -ForegroundColor Cyan
Write-Host "  • Frontend only: .\run-tests-enhanced.ps1 -TestType frontend" -ForegroundColor White
Write-Host "  • Backend only: .\run-tests-enhanced.ps1 -TestType backend" -ForegroundColor White
Write-Host "  • With coverage: .\run-tests-enhanced.ps1 -TestType all -Coverage" -ForegroundColor White
Write-Host "  • Integration only: " -NoNewline -ForegroundColor White
Write-Host ".\run-tests-enhanced.ps1 -TestType integration" -ForegroundColor White