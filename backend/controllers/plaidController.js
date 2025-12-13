const plaidService = require('../services/plaidService');

exports.linkAccount = async (req, res) => {
  try {
    const { public_token } = req.body;
    const userId = req.user._id;

    if (!public_token) {
      return res.status(400).json({
        success: false,
        error: 'Public token is required'
      });
    }

    const accessToken = await plaidService.exchangePublicToken(public_token);
    
    // Store the access token with the user (you might want to create a separate model for this)
    // For now, we'll just return the access token
    
    res.json({
      success: true,
      message: 'Account linked successfully',
      data: { accessToken }
    });
  } catch (error) {
    console.error('Link account error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to link account'
    });
  }
};

exports.getTransactions = async (req, res) => {
  try {
    const { accessToken, startDate, endDate } = req.query;
    const userId = req.user._id;

    if (!accessToken) {
      return res.status(400).json({
        success: false,
        error: 'Access token is required'
      });
    }

    const transactions = await plaidService.fetchTransactions(accessToken, startDate, endDate);
    
    res.json({
      success: true,
      data: {
        transactions,
        count: transactions.length
      }
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to fetch transactions'
    });
  }
};

exports.createLinkToken = async (req, res) => {
  try {
    const userId = req.user._id;
    const linkToken = await plaidService.createLinkToken(userId);
    
    res.json({
      success: true,
      data: {
        link_token: linkToken
      }
    });
  } catch (error) {
    console.error('Create link token error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to create link token'
    });
  }
};

exports.cloudOCR = async (req, res) => {
  try {
    const { image } = req.body;
    const userId = req.user._id;

    if (!image) {
      return res.status(400).json({
        success: false,
        error: 'No image provided'
      });
    }

    const text = await plaidService.cloudOCRService(image);
    
    res.json({
      success: true,
      data: {
        text,
        extracted: text.length > 0
      }
    });
  } catch (error) {
    console.error('Cloud OCR error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process image'
    });
  }
}; 