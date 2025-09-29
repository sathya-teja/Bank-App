// src/routes/transaction.js
import express from 'express';
import { authMiddleware, requireRole } from '../middleware/auth.js';
import { deposit, withdraw, transfer } from '../controllers/transactionController.js';
import { myRecentTransactions } from '../controllers/transactionController.js';

const router = express.Router();

// Admin deposit (or webhook)
router.post('/deposit', authMiddleware, requireRole('admin'), deposit);

// Withdraw (owner or admin)
router.post('/withdraw', authMiddleware, withdraw);

// Transfer (owner can transfer from own account)
router.post('/transfer', authMiddleware, transfer);

// Get recent transactions for logged-in user
router.get('/my', authMiddleware, myRecentTransactions);

export default router;
