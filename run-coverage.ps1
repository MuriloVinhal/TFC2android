# Test Coverage Script for PetTime Project
# Generate coverage reports for both frontend and backend

Write-Host "📊 Generating Coverage Reports..." -ForegroundColor Yellow

# Backend Coverage
Write-Host "`n📦 Generating Backend Coverage..." -ForegroundColor Cyan
Set-Location "pettime-backend"

if (!(Test-Path "node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    npm install
}

Write-Host "Running Jest with coverage..." -ForegroundColor Green
npm run test:coverage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend coverage generation failed!" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

Write-Host "✅ Backend coverage report generated in coverage/" -ForegroundColor Green

# Frontend Coverage
Set-Location ".."
Write-Host "`n📱 Generating Frontend Coverage..." -ForegroundColor Cyan
Set-Location "pettime_frontend"

if (!(Test-Path "pubspec.lock")) {
    Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
}

Write-Host "Running Flutter tests with coverage..." -ForegroundColor Green
flutter test --coverage

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend coverage generation failed!" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

# Generate HTML coverage report for Flutter
if (Get-Command "genhtml" -ErrorAction SilentlyContinue) {
    Write-Host "Generating HTML coverage report..." -ForegroundColor Green
    genhtml coverage/lcov.info -o coverage/html
    Write-Host "✅ Flutter coverage report generated in coverage/html/" -ForegroundColor Green
} else {
    Write-Host "⚠️ genhtml not found. Install lcov for HTML reports." -ForegroundColor Yellow
    Write-Host "✅ Flutter coverage data available in coverage/lcov.info" -ForegroundColor Green
}

Set-Location ".."
Write-Host "`n🎉 Coverage reports generated successfully!" -ForegroundColor Green
Write-Host "Backend: pettime-backend/coverage/" -ForegroundColor Cyan
Write-Host "Frontend: pettime_frontend/coverage/" -ForegroundColor Cyan