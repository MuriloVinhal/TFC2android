import express from 'express';
import { register, login } from '../controllers/authController.js';

const router = express.Router();

// Rota para registro de usuário
router.post('/register', register);

// Rota para login de usuário
router.post('/login', login);

export default router;