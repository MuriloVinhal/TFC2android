# Enhanced Test Automation Script for PetTime
# Complete test execution with detailed reporting

param(
    [string]$TestType = "all",  # all, frontend, backend, unit, integration
    [switch]$Coverage = $false,
    [switch]$Verbose = $false,
    [string]$OutputDir = "test-results"
)

# Configuration
$ErrorActionPreference = "Continue"
$ProjectRoot = Get-Location
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = "$OutputDir\test-log-$Timestamp.txt"

# Ensure output directory exists
if (!(Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

# Logging function
function Write-Log {
    param($Message, $Level = "INFO")
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage -ForegroundColor $(if($Level -eq "ERROR") {"Red"} elseif($Level -eq "SUCCESS") {"Green"} else {"White"})
    Add-Content -Path $LogFile -Value $LogMessage
}

function Test-Prerequisites {
    Write-Log "Checking prerequisites..." "INFO"
    
    # Check Flutter
    try {
        $flutterVersion = flutter --version 2>&1
        if ($flutterVersion -match "Flutter") {
            Write-Log "✅ Flutter SDK found" "SUCCESS"
        } else {
            Write-Log "❌ Flutter SDK not found" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ Flutter SDK not accessible" "ERROR"
        return $false
    }
    
    # Check Node.js
    try {
        $nodeVersion = node --version 2>&1
        if ($nodeVersion -match "v\d+") {
            Write-Log "✅ Node.js found: $nodeVersion" "SUCCESS"
        } else {
            Write-Log "❌ Node.js not found" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ Node.js not accessible" "ERROR"
        return $false
    }
    
    return $true
}

function Run-FrontendTests {
    Write-Log "🧪 Starting Frontend Tests..." "INFO"
    Set-Location "pettime_frontend"
    
    try {
        # Install dependencies if needed
        if (!(Test-Path "pubspec.lock") -or $Verbose) {
            Write-Log "Installing Flutter dependencies..." "INFO"
            flutter pub get 2>&1 | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        }
        
        if ($Coverage) {
            Write-Log "Running Flutter tests with coverage..." "INFO"
            $testResult = flutter test --coverage 2>&1
        } else {
            Write-Log "Running Flutter tests..." "INFO"
            $testResult = flutter test --reporter=expanded 2>&1
        }
        
        $testResult | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Frontend tests passed!" "SUCCESS"
            
            if ($Coverage -and (Test-Path "coverage\lcov.info")) {
                Write-Log "📊 Coverage report generated: coverage\lcov.info" "INFO"
                
                # Generate HTML coverage if genhtml is available
                try {
                    genhtml coverage\lcov.info -o coverage\html 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Log "📊 HTML coverage report: coverage\html\index.html" "SUCCESS"
                    }
                } catch {
                    Write-Log "⚠️ genhtml not available for HTML coverage report" "INFO"
                }
            }
            
            return $true
        } else {
            Write-Log "❌ Frontend tests failed!" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ Error running frontend tests: $_" "ERROR"
        return $false
    } finally {
        Set-Location $ProjectRoot
    }
}

function Run-BackendTests {
    Write-Log "🧪 Starting Backend Tests..." "INFO"
    Set-Location "pettime-backend"
    
    try {
        # Install dependencies if needed
        if (!(Test-Path "node_modules") -or $Verbose) {
            Write-Log "Installing Node.js dependencies..." "INFO"
            npm install 2>&1 | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        }
        
        if ($Coverage) {
            Write-Log "Running Jest tests with coverage..." "INFO"
            $testResult = npm run test:coverage 2>&1
        } else {
            Write-Log "Running Jest tests..." "INFO"
            $testResult = npm test -- --verbose 2>&1
        }
        
        $testResult | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Backend tests passed!" "SUCCESS"
            
            if ($Coverage -and (Test-Path "coverage")) {
                Write-Log "📊 Coverage report generated: coverage\index.html" "SUCCESS"
            }
            
            return $true
        } else {
            Write-Log "❌ Backend tests failed!" "ERROR"
            return $false
        }
    } catch {
        Write-Log "❌ Error running backend tests: $_" "ERROR"
        return $false
    } finally {
        Set-Location $ProjectRoot
    }
}

function Run-IntegrationTests {
    Write-Log "🔗 Starting Integration Tests..." "INFO"
    
    # Run backend integration tests
    Set-Location "pettime-backend"
    try {
        Write-Log "Running backend integration tests..." "INFO"
        $testResult = npm test -- --testPathPattern=integration 2>&1
        $testResult | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        
        if ($LASTEXITCODE -ne 0) {
            Write-Log "⚠️ Backend integration tests had issues" "ERROR"
        }
    } catch {
        Write-Log "⚠️ Error running backend integration tests: $_" "ERROR"
    }
    
    Set-Location $ProjectRoot
    
    # Run frontend integration tests
    Set-Location "pettime_frontend"
    try {
        Write-Log "Running frontend integration tests..." "INFO"
        $testResult = flutter test test/integration/ 2>&1
        $testResult | Tee-Object -FilePath "$ProjectRoot\$LogFile" -Append
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Integration tests completed!" "SUCCESS"
            return $true
        } else {
            Write-Log "⚠️ Some integration tests had issues" "ERROR"
            return $false
        }
    } catch {
        Write-Log "⚠️ Error running frontend integration tests: $_" "ERROR"
        return $false
    } finally {
        Set-Location $ProjectRoot
    }
}

function Generate-TestReport {
    Write-Log "📋 Generating test report..." "INFO"
    
    $reportPath = "$OutputDir\test-report-$Timestamp.html"
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>PetTime Test Report - $Timestamp</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2196F3; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background: #E8F5E8; border-color: #4CAF50; }
        .error { background: #FFF0F0; border-color: #F44336; }
        .info { background: #F0F8FF; border-color: #2196F3; }
        .coverage { background: #FFF8E1; border-color: #FF9800; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 PetTime Test Suite Report</h1>
        <p class="timestamp">Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    </div>
    
    <div class="section info">
        <h2>📊 Test Summary</h2>
        <ul>
            <li><strong>Test Type:</strong> $TestType</li>
            <li><strong>Coverage Enabled:</strong> $Coverage</li>
            <li><strong>Verbose Mode:</strong> $Verbose</li>
            <li><strong>Log File:</strong> $LogFile</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>🎯 Test Results</h2>
        <p>Detailed results are available in the log file.</p>
        <p><strong>Frontend Tests:</strong> $(if($frontendSuccess) {"✅ PASSED"} else {"❌ FAILED"})</p>
        <p><strong>Backend Tests:</strong> $(if($backendSuccess) {"✅ PASSED"} else {"❌ FAILED"})</p>
        $(if($TestType -eq "all" -or $TestType -eq "integration") {
            "<p><strong>Integration Tests:</strong> $(if($integrationSuccess) {"✅ PASSED"} else {"❌ FAILED"})</p>"
        })
    </div>
    
    $(if($Coverage) {
        @"
        <div class="section coverage">
            <h2>📈 Coverage Reports</h2>
            <ul>
                <li><strong>Frontend Coverage:</strong> <a href="pettime_frontend/coverage/html/index.html">HTML Report</a> | <a href="pettime_frontend/coverage/lcov.info">LCOV Data</a></li>
                <li><strong>Backend Coverage:</strong> <a href="pettime-backend/coverage/index.html">HTML Report</a></li>
            </ul>
        </div>
"@
    })
    
    <div class="section">
        <h2>🔍 Test Structure</h2>
        <h3>Frontend Tests:</h3>
        <ul>
            <li>Unit Tests: Authentication, Home, User modules</li>
            <li>Widget Tests: Custom components and UI</li>
            <li>Integration Tests: Complete app flows</li>
        </ul>
        
        <h3>Backend Tests:</h3>
        <ul>
            <li>Unit Tests: Services, utilities, password handling</li>
            <li>Controller Tests: API endpoints and business logic</li>
            <li>Integration Tests: End-to-end API flows</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>📝 Next Steps</h2>
        <ul>
            <li>Review failed tests in the log file</li>
            <li>Check coverage reports for areas needing more tests</li>
            <li>Run tests individually for detailed debugging</li>
            <li>Update tests as new features are added</li>
        </ul>
    </div>
</body>
</html>
"@
    
    $htmlReport | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Log "📋 Test report generated: $reportPath" "SUCCESS"
}

# Main execution
Write-Log "🚀 Starting PetTime Test Suite" "INFO"
Write-Log "Test Type: $TestType, Coverage: $Coverage, Verbose: $Verbose" "INFO"

if (!(Test-Prerequisites)) {
    Write-Log "❌ Prerequisites check failed. Exiting." "ERROR"
    exit 1
}

$frontendSuccess = $false
$backendSuccess = $false
$integrationSuccess = $false

switch ($TestType.ToLower()) {
    "frontend" {
        $frontendSuccess = Run-FrontendTests
    }
    "backend" {
        $backendSuccess = Run-BackendTests
    }
    "integration" {
        $integrationSuccess = Run-IntegrationTests
    }
    "unit" {
        $frontendSuccess = Run-FrontendTests
        $backendSuccess = Run-BackendTests
    }
    "all" {
        $frontendSuccess = Run-FrontendTests
        $backendSuccess = Run-BackendTests
        $integrationSuccess = Run-IntegrationTests
    }
    default {
        Write-Log "❌ Invalid test type: $TestType. Use: all, frontend, backend, unit, integration" "ERROR"
        exit 1
    }
}

# Generate final report
Generate-TestReport

# Final summary
$overallSuccess = $true
if ($TestType -eq "all") {
    $overallSuccess = $frontendSuccess -and $backendSuccess -and $integrationSuccess
} elseif ($TestType -eq "unit") {
    $overallSuccess = $frontendSuccess -and $backendSuccess
} elseif ($TestType -eq "frontend") {
    $overallSuccess = $frontendSuccess
} elseif ($TestType -eq "backend") {
    $overallSuccess = $backendSuccess
} elseif ($TestType -eq "integration") {
    $overallSuccess = $integrationSuccess
}

if ($overallSuccess) {
    Write-Log "🎉 All tests completed successfully!" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ Some tests failed. Check the report for details." "ERROR"
    exit 1
}