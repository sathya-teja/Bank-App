// src/models/Account.js
import mongoose from 'mongoose';

const savingsGoalSchema = new mongoose.Schema({
  title: { type: String, required: true },
  targetAmount: { type: Number, required: true },   // stored in paise
  savedAmount: { type: Number, default: 0 },        // stored in paise
}, { timestamps: true });

const accountSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  accountNumber: { type: String, unique: true, required: true },
  type: { type: String, enum: ['SAV', 'CUR'], default: 'SAV' },
  balance: { type: Number, default: 0 },            // stored in paise
  currency: { type: String, default: 'INR' },
  status: { type: String, enum: ['active', 'frozen', 'closed'], default: 'active' },
  createdAt: { type: Date, default: Date.now },

  // ✅ Add this field
  savingsGoals: [savingsGoalSchema]
});

export default mongoose.model('Account', accountSchema);
