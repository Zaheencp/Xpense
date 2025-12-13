const plaid = require('plaid');
require('dotenv').config();
const axios = require('axios');

const client = new plaid.PlaidApi(
  new plaid.Configuration({
    basePath: plaid.PlaidEnvironments[process.env.PLAID_ENV || 'sandbox'],
    baseOptions: {
      headers: {
        'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
        'PLAID-SECRET': process.env.PLAID_SECRET,
      },
    },
  })
);

exports.exchangePublicToken = async (publicToken) => {
  try {
    const response = await client.itemPublicTokenExchange({ 
      public_token: publicToken 
    });
    return response.data.access_token;
  } catch (error) {
    console.error('Plaid token exchange error:', error);
    throw new Error('Failed to exchange public token');
  }
};

exports.fetchTransactions = async (accessToken, startDate, endDate) => {
  try {
    const now = new Date();
    const defaultStartDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
    const defaultEndDate = now;

    const start = startDate ? new Date(startDate) : defaultStartDate;
    const end = endDate ? new Date(endDate) : defaultEndDate;

    const response = await client.transactionsGet({
      access_token: accessToken,
      start_date: start.toISOString().split('T')[0],
      end_date: end.toISOString().split('T')[0],
      options: { 
        count: 100, 
        offset: 0,
        include_personal_finance_category: true
      },
    });

    return response.data.transactions || [];
  } catch (error) {
    console.error('Plaid fetch transactions error:', error);
    throw new Error('Failed to fetch transactions from Plaid');
  }
};

exports.createLinkToken = async (userId) => {
  try {
    const response = await client.linkTokenCreate({
      user: { client_user_id: userId.toString() },
      client_name: 'SpendWise',
      products: ['transactions'],
      country_codes: ['US'],
      language: 'en',
      redirect_uri: process.env.PLAID_REDIRECT_URI || 'http://localhost:3000/redirect',
      account_filters: {
        depository: {
          account_subtypes: ['checking', 'savings']
        },
        credit: {
          account_subtypes: ['credit card']
        }
      }
    });
    return response.data.link_token;
  } catch (error) {
    console.error('Plaid create link token error:', error);
    throw new Error('Failed to create link token');
  }
};

exports.cloudOCRService = async (base64Image) => {
  try {
    const apiKey = process.env.GOOGLE_CLOUD_VISION_API_KEY;
    if (!apiKey) {
      throw new Error('Google Cloud Vision API key not configured');
    }

    const url = `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`;
    const body = {
      requests: [
        {
          image: { content: base64Image },
          features: [{ type: 'TEXT_DETECTION' }],
        },
      ],
    };

    const response = await axios.post(url, body);
    const text = response.data.responses[0]?.fullTextAnnotation?.text || '';
    
    return text;
  } catch (error) {
    console.error('Google Cloud Vision error:', error);
    throw new Error('Failed to process image with OCR');
  }
};

// Additional Plaid utilities
exports.getAccountBalance = async (accessToken) => {
  try {
    const response = await client.accountsBalanceGet({
      access_token: accessToken
    });
    return response.data.accounts;
  } catch (error) {
    console.error('Plaid get balance error:', error);
    throw new Error('Failed to fetch account balance');
  }
};

exports.getItemInfo = async (accessToken) => {
  try {
    const response = await client.itemGet({
      access_token: accessToken
    });
    return response.data.item;
  } catch (error) {
    console.error('Plaid get item info error:', error);
    throw new Error('Failed to fetch item information');
  }
}; 