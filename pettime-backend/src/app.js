const express = require('express');
const cors = require('cors');
// require('dotenv').config(); // Removido, já está no server.js

const app = express();

// ✅ Habilita CORS antes de tudo
app.use(cors());

// ✅ Permite JSON no body das requisições
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Middleware para logar todas as requisições
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - IP: ${req.ip}`);
    next();
});

// ✅ Rotas
const usuarioRoutes = require('./routes/usuarioRoutes');
app.use('/usuarios', usuarioRoutes);

const petRoutes = require('./routes/petRoutes');
app.use('/pets', petRoutes);

const tosaRoutes = require('./routes/tosaRoutes');
const servicoAdicionalRoutes = require('./routes/servicoadicionalRoutes');
const produtoRoutes = require('./routes/produtoRoutes');
const agendamentosRouter = require('./routes/agendamentos');
const notificacaoRoutes = require('./routes/notificacaoRoutes');

app.use('/tosas', tosaRoutes);
app.use('/servicos-adicionais', servicoAdicionalRoutes);
app.use('/produtos', produtoRoutes);
app.use('/agendamentos', agendamentosRouter);
app.use('/notificacoes', notificacaoRoutes);

app.use('/uploads', express.static('uploads'));

// ✅ Conexão com Sequelize/PostgreSQL
const sequelize = require('./config/database');

sequelize.authenticate()
    .then(() => {
        console.log('✅ Conexão com o PostgreSQL bem-sucedida!');
    })
    .catch((error) => {
        console.error('❌ Erro ao conectar com o PostgreSQL:', error);
    });

// ✅ Exporta app para uso no server.js
module.exports = app;
