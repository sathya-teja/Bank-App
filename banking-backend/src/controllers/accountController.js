// src/controllers/accountController.js
import Account from '../models/Account.js';
import CustomerProfile from '../models/CustomerProfile.js';
import Transaction from '../models/Transaction.js';
import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

function generateAccountNumber() {
  return uuidv4().replace(/-/g, '').slice(0, 12);
}

// ✅ Convert rupees to paise for safe integer storage
function toPaise(amount) {
  return Math.round(Number(amount) * 100);
}

// ----------------- Create Account -----------------
export async function createAccount(req, res) {
  try {
    if (req.user.role === 'admin') {
      return res.status(403).json({ error: 'Admins cannot create accounts' });
    }

    const profile = await CustomerProfile.findOne({ userId: req.user.id });
    if (!profile) return res.status(400).json({ error: 'Complete KYC profile first' });
    if (profile.kycStatus !== 'verified') {
      return res.status(403).json({ error: 'KYC not verified yet' });
    }

    const { type } = req.body;
    const account = await Account.create({
      userId: req.user.id,
      accountNumber: generateAccountNumber(),
      type: type || 'SAV',
      balance: 0
    });
    res.status(201).json({ ok: true, account });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

// ----------------- Get Accounts -----------------
export async function getMyAccounts(req, res) {
  try {
    const accounts = await Account.find({ userId: req.user.id });
    res.json({ ok: true, accounts });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

export async function getAccountById(req, res) {
  try {
    const account = await Account.findById(req.params.id);
    if (!account) return res.status(404).json({ error: 'Account not found' });

    if (req.user.role !== 'admin' && account.userId.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    res.json({ ok: true, account });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

// ----------------- Savings Goals -----------------
export async function createSavingsGoal(req, res) {
  try {
    const { accountNumber, title, targetAmount } = req.body;
    if (!accountNumber || !title || !targetAmount) {
      return res.status(400).json({ error: "accountNumber, title, targetAmount required" });
    }

    const account = await Account.findOne({ accountNumber });
    if (!account) return res.status(404).json({ error: "Account not found" });

    if (req.user.role !== "admin" && account.userId.toString() !== req.user.id) {
      return res.status(403).json({ error: "Forbidden" });
    }

    const goal = { title, targetAmount: toPaise(targetAmount), savedAmount: 0 };
    account.savingsGoals.push(goal);
    await account.save();

    res.status(201).json({ ok: true, savingsGoals: account.savingsGoals });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
}

export async function contributeToSavingsGoal(req, res) {
  const session = await mongoose.startSession();
  try {
    const { accountNumber, goalId, amount } = req.body;
    if (!accountNumber || !goalId || amount == null) {
      return res.status(400).json({ error: "accountNumber, goalId, amount required" });
    }

    const amt = toPaise(amount);
    if (amt <= 0) return res.status(400).json({ error: "amount must be positive" });

    session.startTransaction();

    const account = await Account.findOne({ accountNumber }).session(session);
    if (!account) throw new Error("Account not found");

    if (req.user.role !== "admin" && account.userId.toString() !== req.user.id) {
      throw new Error("Forbidden");
    }

    if (account.status !== "active") throw new Error("Account not active");
    if (account.balance < amt) throw new Error("INSUFFICIENT_FUNDS");

    const goal = account.savingsGoals.id(goalId);
    if (!goal) throw new Error("Savings goal not found");

    // Deduct from account balance
    account.balance -= amt;
    goal.savedAmount += amt;

    await account.save({ session });

    // Record transaction
    const txn = await Transaction.create([{
      accountId: account._id,
      type: "DEBIT",
      amount: amt,
      balanceAfter: account.balance,
      description: `Savings Contribution - ${goal.title}`,
    }], { session });

    await session.commitTransaction();
    res.status(200).json({ ok: true, goal, transaction: txn[0] });
  } catch (e) {
    await session.abortTransaction();
    res.status(400).json({ error: e.message });
  } finally {
    session.endSession();
  }
}

export async function getSavingsGoals(req, res) {
  try {
    const { accountNumber } = req.params;
    const account = await Account.findOne({ accountNumber });
    if (!account) return res.status(404).json({ error: "Account not found" });

    if (req.user.role !== "admin" && account.userId.toString() !== req.user.id) {
      return res.status(403).json({ error: "Forbidden" });
    }

    res.json(account.savingsGoals);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
