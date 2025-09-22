# Test Runner Script for PetTime Project
# Run all tests for both frontend and backend

Write-Host "🧪 Running PetTime Test Suite..." -ForegroundColor Yellow

# Backend Tests
Write-Host "`n📦 Running Backend Tests..." -ForegroundColor Cyan
Set-Location "pettime-backend"

# Install dependencies if needed
if (!(Test-Path "node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    npm install
}

# Run backend tests
Write-Host "Running Jest tests..." -ForegroundColor Green
npm test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Backend tests failed!" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

Write-Host "✅ Backend tests passed!" -ForegroundColor Green

# Frontend Tests
Set-Location ".."
Write-Host "`n📱 Running Frontend Tests..." -ForegroundColor Cyan
Set-Location "pettime_frontend"

# Get dependencies if needed
if (!(Test-Path "pubspec.lock")) {
    Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
}

# Run Flutter tests
Write-Host "Running Flutter tests..." -ForegroundColor Green
flutter test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Frontend tests failed!" -ForegroundColor Red
    Set-Location ".."
    exit 1
}

Write-Host "✅ Frontend tests passed!" -ForegroundColor Green

Set-Location ".."
Write-Host "`n🎉 All tests passed successfully!" -ForegroundColor Green