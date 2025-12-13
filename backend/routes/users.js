const express = require('express');
const auth = require('../middleware/auth');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

const router = express.Router();

// All user routes require authentication
router.use(auth);

// @route   GET /api/users/stats
// @desc    Get user statistics
// @access  Private
router.get('/stats', async (req, res) => {
  try {
    const userId = req.user._id;
    
    // Get current month's transactions
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    const monthlyTransactions = await Transaction.find({
      user: userId,
      date: { $gte: startOfMonth, $lte: endOfMonth }
    });

    // Calculate statistics
    const totalExpenses = monthlyTransactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalIncome = monthlyTransactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0);

    const netAmount = totalIncome - totalExpenses;

    // Category breakdown
    const categoryBreakdown = {};
    monthlyTransactions
      .filter(t => t.type === 'expense')
      .forEach(t => {
        categoryBreakdown[t.category] = (categoryBreakdown[t.category] || 0) + t.amount;
      });

    // Top spending categories
    const topCategories = Object.entries(categoryBreakdown)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5)
      .map(([category, amount]) => ({ category, amount }));

    res.json({
      success: true,
      data: {
        monthlyStats: {
          totalExpenses,
          totalIncome,
          netAmount,
          transactionCount: monthlyTransactions.length
        },
        topCategories,
        categoryBreakdown
      }
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

// @route   GET /api/users/dashboard
// @desc    Get dashboard data
// @access  Private
router.get('/dashboard', async (req, res) => {
  try {
    const userId = req.user._id;
    
    // Get recent transactions
    const recentTransactions = await Transaction.find({ user: userId })
      .sort({ date: -1 })
      .limit(10);

    // Get monthly spending trend (last 6 months)
    const monthlyTrend = [];
    for (let i = 5; i >= 0; i--) {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      const startOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
      const endOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0);

      const monthTransactions = await Transaction.find({
        user: userId,
        date: { $gte: startOfMonth, $lte: endOfMonth },
        type: 'expense'
      });

      const totalSpent = monthTransactions.reduce((sum, t) => sum + t.amount, 0);
      
      monthlyTrend.push({
        month: date.toLocaleString('default', { month: 'short' }),
        year: date.getFullYear(),
        amount: totalSpent
      });
    }

    res.json({
      success: true,
      data: {
        recentTransactions,
        monthlyTrend
      }
    });
  } catch (error) {
    console.error('Get dashboard error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
});

module.exports = router;













