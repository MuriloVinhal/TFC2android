# Test Watch Script for PetTime Project
# Run tests in watch mode for development

Write-Host "👀 Starting Test Watch Mode..." -ForegroundColor Yellow
Write-Host "Choose an option:" -ForegroundColor Cyan
Write-Host "1. Backend only" -ForegroundColor White
Write-Host "2. Frontend only" -ForegroundColor White
Write-Host "3. Both (in separate terminals)" -ForegroundColor White

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host "Starting backend test watch..." -ForegroundColor Green
        Set-Location "pettime-backend"
        npm run test:watch
    }
    "2" {
        Write-Host "Starting frontend test watch..." -ForegroundColor Green
        Set-Location "pettime_frontend"
        # Flutter doesn't have built-in watch mode, but we can simulate it
        Write-Host "Running Flutter tests (manual restart required)..." -ForegroundColor Yellow
        flutter test
    }
    "3" {
        Write-Host "Opening backend test watch in new terminal..." -ForegroundColor Green
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd pettime-backend; npm run test:watch"
        
        Write-Host "Starting frontend tests..." -ForegroundColor Green
        Set-Location "pettime_frontend"
        flutter test
    }
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
        exit 1
    }
}