# Script para limpar banco de dados do PetTime
# Preserva admin (id=1) e tabelas do Sequelize

param(
    [string]$AdminId = "1",
    [string]$AdminTable = "usuarios", 
    [string]$ExcludeTables = "SequelizeMeta,SequelizeData"
)

Write-Host "🗄️ Limpeza do Banco de Dados PetTime" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Verificar se Node.js está disponível
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js detectado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js não encontrado. Instale Node.js primeiro." -ForegroundColor Red
    exit 1
}

# Navegar para o diretório do backend
$backendPath = "pettime-backend"
if (-not (Test-Path $backendPath)) {
    Write-Host "❌ Diretório $backendPath não encontrado" -ForegroundColor Red
    exit 1
}

Set-Location $backendPath

# Verificar se o script de limpeza existe
$cleanScript = "..\scripts\clean-db.js"
if (-not (Test-Path $cleanScript)) {
    Write-Host "❌ Script clean-db.js não encontrado em scripts/" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Verificar se as dependências estão instaladas
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️ Dependências não instaladas. Instalando..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Falha ao instalar dependências" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
}

# Configurar variáveis de ambiente do banco
Write-Host "🔧 Configurando conexão com banco..." -ForegroundColor Yellow

# Tentar ler configuração do config/config.js
$configFile = "src\config\config.js"
if (Test-Path $configFile) {
    Write-Host "📄 Usando configuração de $configFile" -ForegroundColor Green
    
    # Valores padrão baseados no projeto
    $env:DB_DIALECT = "postgres"
    $env:DB_HOST = "localhost"
    $env:DB_PORT = "5432"
    $env:DB_NAME = "pettime"
    $env:DB_USER = "postgres" 
    $env:DB_PASS = "password"
} else {
    Write-Host "⚠️ Arquivo de configuração não encontrado. Usando valores padrão." -ForegroundColor Yellow
    
    # Configuração padrão
    $env:DB_DIALECT = "postgres"
    $env:DB_HOST = "localhost" 
    $env:DB_PORT = "5432"
    $env:DB_NAME = "pettime"
    $env:DB_USER = "postgres"
    $env:DB_PASS = "password"
}

# Configurar parâmetros de limpeza
$env:ADMIN_TABLE = $AdminTable
$env:ADMIN_ID = $AdminId
$env:EXCLUDE_TABLES = $ExcludeTables

Write-Host "📋 Configuração:" -ForegroundColor Cyan
Write-Host "  Database: $($env:DB_DIALECT)://$($env:DB_HOST):$($env:DB_PORT)/$($env:DB_NAME)" -ForegroundColor White
Write-Host "  Admin Table: $AdminTable (ID: $AdminId)" -ForegroundColor White
Write-Host "  Tabelas Preservadas: $ExcludeTables" -ForegroundColor White

# Confirmar execução
Write-Host ""
$confirmation = Read-Host "⚠️ ATENÇÃO: Isso irá limpar TODOS os dados do banco (exceto admin). Continuar? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "❌ Operação cancelada pelo usuário" -ForegroundColor Yellow
    Set-Location ..
    exit 0
}

Write-Host ""
Write-Host "🚀 Iniciando limpeza do banco..." -ForegroundColor Green

# Executar script de limpeza
try {
    node $cleanScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Limpeza concluída com sucesso!" -ForegroundColor Green
        Write-Host "🔒 Admin preservado (Tabela: $AdminTable, ID: $AdminId)" -ForegroundColor Cyan
        Write-Host "📊 Metadados Sequelize preservados" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Erro durante a limpeza (código: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "❌ Erro ao executar script: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location ..
}

Write-Host ""
Write-Host "📝 Para personalizar a execução:" -ForegroundColor Cyan
Write-Host "  .\clean-database.ps1 -AdminId 5 -AdminTable usuarios -ExcludeTables 'SequelizeMeta,SequelizeData,configuracoes'" -ForegroundColor White
