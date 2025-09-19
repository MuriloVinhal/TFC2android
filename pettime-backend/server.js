require('dotenv').config();
const app = require('./src/app');
const PORT = process.env.PORT || 3000;

app.listen(3000, '0.0.0.0', () => {
    console.log('Servidor rodando na porta 3000');
});
