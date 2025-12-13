const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  amount: {
    type: Number,
    required: [true, 'Amount is required'],
    min: [0.01, 'Amount must be greater than 0']
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Entertainment',
      'Healthcare',
      'Education',
      'Housing',
      'Utilities',
      'Insurance',
      'Investment',
      'Income',
      'Other'
    ]
  },
  date: {
    type: Date,
    required: [true, 'Date is required'],
    default: Date.now
  },
  memo: {
    type: String,
    maxlength: [500, 'Memo cannot exceed 500 characters'],
    default: ''
  },
  type: {
    type: String,
    enum: ['expense', 'income'],
    required: true,
    default: 'expense'
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'bank_transfer', 'digital_wallet', 'other'],
    default: 'card'
  },
  tags: [{
    type: String,
    maxlength: 50
  }],
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringInterval: {
    type: String,
    enum: ['weekly', 'monthly', 'yearly'],
    required: function() { return this.isRecurring; }
  },
  attachments: [{
    filename: String,
    url: String,
    type: String
  }]
}, {
  timestamps: true
});

// Index for better query performance
transactionSchema.index({ user: 1, date: -1 });
transactionSchema.index({ user: 1, category: 1 });
transactionSchema.index({ user: 1, type: 1 });

// Virtual for formatted amount
transactionSchema.virtual('formattedAmount').get(function() {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  }).format(this.amount);
});

// Ensure virtuals are serialized
transactionSchema.set('toJSON', { virtuals: true });
transactionSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Transaction', transactionSchema);













