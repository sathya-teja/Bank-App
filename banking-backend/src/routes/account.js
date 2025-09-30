// src/routes/account.js
import express from 'express';
import { authMiddleware  } from '../middleware/auth.js';
import { createAccount, getMyAccounts, getAccountById,createSavingsGoal,contributeToSavingsGoal,getSavingsGoals } from '../controllers/accountController.js';

const router = express.Router();

router.post('/', authMiddleware, createAccount);       // Create account
router.get('/', authMiddleware, getMyAccounts);        // My accounts
router.get('/:id', authMiddleware, getAccountById);    // Account details
router.post("/goal", authMiddleware, createSavingsGoal);
router.post("/goal/contribute", authMiddleware, contributeToSavingsGoal);
router.get("/:accountNumber/goals", authMiddleware, getSavingsGoals);

export default router;
