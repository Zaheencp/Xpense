const express = require('express');
const { body, validationResult } = require('express-validator');
const auth = require('../middleware/auth');
const Transaction = require('../models/Transaction');

const router = express.Router();

// All transaction routes require authentication
router.use(auth);

// @route   GET /api/transactions
// @desc    Get all transactions for the authenticated user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, category, startDate, endDate } = req.query;
    
    const query = { user: req.user._id };
    
    if (category) {
      query.category = category;
    }
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const transactions = await Transaction.find(query)
      .sort({ date: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Transaction.countDocuments(query);

    res.json({
      success: true,
      data: {
        transactions,
        totalPages: Math.ceil(total / limit),
        currentPage: page,
        total
      }
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @route   POST /api/transactions
// @desc    Create a new transaction
// @access  Private
router.post('/', [
  body('amount')
    .isFloat({ min: 0.01 })
    .withMessage('Amount must be a positive number'),
  body('category')
    .notEmpty()
    .withMessage('Category is required'),
  body('date')
    .isISO8601()
    .withMessage('Date must be a valid date'),
  body('memo')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Memo cannot exceed 500 characters')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const { amount, category, date, memo } = req.body;

    const transaction = new Transaction({
      user: req.user._id,
      amount,
      category,
      date: new Date(date),
      memo: memo || ''
    });

    await transaction.save();

    res.status(201).json({
      success: true,
      message: 'Transaction created successfully',
      data: {
        transaction
      }
    });
  } catch (error) {
    console.error('Create transaction error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @route   PUT /api/transactions/:id
// @desc    Update a transaction
// @access  Private
router.put('/:id', [
  body('amount')
    .optional()
    .isFloat({ min: 0.01 })
    .withMessage('Amount must be a positive number'),
  body('category')
    .optional()
    .notEmpty()
    .withMessage('Category cannot be empty'),
  body('date')
    .optional()
    .isISO8601()
    .withMessage('Date must be a valid date'),
  body('memo')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Memo cannot exceed 500 characters')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array()
      });
    }

    const transaction = await Transaction.findOne({
      _id: req.params.id,
      user: req.user._id
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        error: 'Transaction not found'
      });
    }

    const { amount, category, date, memo } = req.body;
    
    if (amount !== undefined) transaction.amount = amount;
    if (category !== undefined) transaction.category = category;
    if (date !== undefined) transaction.date = new Date(date);
    if (memo !== undefined) transaction.memo = memo;

    await transaction.save();

    res.json({
      success: true,
      message: 'Transaction updated successfully',
      data: {
        transaction
      }
    });
  } catch (error) {
    console.error('Update transaction error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @route   DELETE /api/transactions/:id
// @desc    Delete a transaction
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const transaction = await Transaction.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        error: 'Transaction not found'
      });
    }

    res.json({
      success: true,
      message: 'Transaction deleted successfully'
    });
  } catch (error) {
    console.error('Delete transaction error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

module.exports = router;

