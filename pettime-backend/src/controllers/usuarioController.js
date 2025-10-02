const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Usuario } = require('../models');
const nodemailer = require('nodemailer');
const { validarEmail } = require('../utils/validators');
const { Op } = require('sequelize');

const JWT_SECRET = process.env.JWT_SECRET;

module.exports = {
    async recuperarSenha(req, res) {
        try {
            const { email } = req.body || {};
            if (!email || !validarEmail(email)) {
                return res.status(400).json({ erro: 'O campo não foi preenchido.', message: 'O campo não foi preenchido.' });
            }

            // Busca case-insensitive (PostgreSQL)
            const emailBusca = email.trim();
            const usuario = await Usuario.findOne({
                where: { email: { [Op.iLike]: emailBusca } }
            });

            if (!usuario) {
                return res.status(404).json({ erro: 'e-mail inexistente', message: 'e-mail inexistente' });
            }

            // Gera senha temporária
            const senhaTemporaria = Math.random().toString(36).slice(-10);
            const hash = await bcrypt.hash(senhaTemporaria, 10);
            await usuario.update({ senha: hash });

            // Envia e-mail com a nova senha (SMTP configurável)
            const useEthereal = ((process.env.EMAIL_USE_ETHEREAL || '').toLowerCase() === 'true');
            let transporter;

            if (useEthereal) {
                const testAccount = await nodemailer.createTestAccount();
                transporter = nodemailer.createTransport({
                    host: 'smtp.ethereal.email',
                    port: 587,
                    secure: false,
                    auth: {
                        user: testAccount.user,
                        pass: testAccount.pass
                    }
                });
            } else {
                const host = (process.env.SMTP_HOST || 'smtp.gmail.com');
                const port = process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT, 10) : 465;
                const secure = process.env.SMTP_SECURE ? /^(true|1)$/i.test(process.env.SMTP_SECURE) : (port === 465);
                const smtpUser = (process.env.SMTP_USER || process.env.EMAIL_USER || '').trim();
                let smtpPass = (process.env.SMTP_PASS || process.env.EMAIL_PASS || '');
                // Se usar Gmail, remover espaços comuns de App Password
                if (/gmail\.com$/i.test(host)) {
                    smtpPass = smtpPass.replace(/\s+/g, '');
                }

                transporter = nodemailer.createTransport({
                    host,
                    port,
                    secure,
                    auth: { user: smtpUser, pass: smtpPass },
                });
            }

            try {
                await transporter.verify();
            } catch (verifyErr) {
                console.error('Falha ao verificar SMTP:', verifyErr);
            }

            const mailOptions = {
                from: `PetTime <${process.env.EMAIL_USER}>`,
                to: usuario.email,
                subject: 'Recuperação de Senha - PetTime',
                text: `Olá, ${usuario.nome}\n\nSua nova senha temporária é: ${senhaTemporaria}\n\nFaça login e altere-a imediatamente nas configurações da sua conta.\n\nSe não foi você que solicitou, ignore este e-mail.`,
            };

            try {
                const info = await transporter.sendMail(mailOptions);
                if (useEthereal) {
                    const preview = nodemailer.getTestMessageUrl(info);
                    console.log('Ethereal preview URL:', preview);
                }
                return res.status(200).json({ mensagem: 'Nova senha enviada para o e-mail cadastrado.', message: 'Nova senha enviada para o e-mail cadastrado.' });
            } catch (errMail) {
                console.error('Erro ao enviar e-mail de recuperação:', errMail);
                return res.status(500).json({ erro: 'Erro ao tentar recuperar senha.', message: 'Erro ao tentar recuperar senha.' });
            }
        } catch (err) {
            console.error('Erro em recuperarSenha:', err);
            return res.status(500).json({ erro: 'Erro ao tentar recuperar senha.', message: 'Erro ao tentar recuperar senha.' });
        }
    },
    async register(req, res) {
        const { nome, email, telefone, endereco, senha, tipo } = req.body;

        try {
            const usuarioExistente = await Usuario.findOne({ where: { email } });
            if (usuarioExistente) {
                return res.status(400).json({ erro: 'E-mail já cadastrado.', message: 'E-mail já cadastrado.' });
            }

            const hash = await bcrypt.hash(senha, 10);

            await Usuario.create({
                nome,
                email,
                telefone,
                endereco,
                senha: hash,
                tipo: tipo || 'cliente'
            });

            return res.status(200).json({ mensagem: 'Usuário criado com sucesso!', message: 'Usuário criado com sucesso!' });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro ao criar usuário.', message: 'Erro ao criar usuário.' });
        }
    },

    async login(req, res) {
        const { email, senha } = req.body;

        try {
            const usuario = await Usuario.findOne({ where: { email } });
            if (!usuario) {
                return res.status(400).json({ erro: 'Usuário não encontrado.', message: 'Usuário não encontrado.' });
            }
            if (usuario.deletado) {
                return res.status(403).json({ erro: 'Usuário excluído. Não é possível fazer login.', message: 'Usuário excluído. Não é possível fazer login.' });
            }
            const senhaValida = await bcrypt.compare(senha, usuario.senha);
            if (!senhaValida) {
                return res.status(401).json({ erro: 'Senha inválida.', message: 'Senha inválida.' });
            }
            const token = jwt.sign({ id: usuario.id, tipo: usuario.tipo }, JWT_SECRET, { expiresIn: '8h' });
            return res.json({ token, usuario: { id: usuario.id, nome: usuario.nome, tipo: usuario.tipo }, message: 'Login realizado com sucesso.' });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro no login.', message: 'Erro no login.' });
        }
    },

    async deleteMe(req, res) {
        try {
            const usuario = await Usuario.findByPk(req.userId);
            if (!usuario) {
                return res.status(404).json({ erro: 'Usuário não encontrado.', message: 'Usuário não encontrado.' });
            }
            await usuario.update({ deletado: true });
            return res.status(200).json({ mensagem: 'Usuário excluído com sucesso!', message: 'Usuário excluído com sucesso!' });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro ao excluir usuário.', message: 'Erro ao excluir usuário.' });
        }
    },
};
