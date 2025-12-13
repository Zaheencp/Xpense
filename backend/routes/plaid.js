const express = require('express');
const router = express.Router();
const plaidController = require('../controllers/plaidController');
const auth = require('../middleware/auth');

// All Plaid routes require authentication
router.use(auth);

router.post('/link', plaidController.linkAccount);
router.get('/transactions', plaidController.getTransactions);
router.post('/create_link_token', plaidController.createLinkToken);
router.post('/cloud-ocr', plaidController.cloudOCR);

module.exports = router; 