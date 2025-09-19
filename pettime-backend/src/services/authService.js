import { Usuario } from '../models/Usuario';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const authService = {
    async register(userData) {
        const { email, password } = userData;
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await Usuario.create({ ...userData, password: hashedPassword });
        return newUser;
    },

    async login(email, password) {
        const user = await Usuario.findOne({ where: { email } });
        if (!user) {
            throw new Error('Usuário não encontrado');
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            throw new Error('Senha inválida');
        }

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return { user, token };
    },

    async verifyToken(token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            return decoded;
        } catch (error) {
            throw new Error('Token inválido');
        }
    }
};

export default authService;