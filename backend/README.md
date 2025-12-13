# SpendWise Backend API

A modern, secure Node.js/Express backend for the SpendWise financial management application.

## 🚀 Features

- **Authentication & Authorization**: JWT-based authentication with bcrypt password hashing
- **User Management**: Complete user registration, login, and profile management
- **Transaction Management**: CRUD operations for financial transactions
- **Plaid Integration**: Secure bank account linking and transaction fetching
- **OCR Receipt Scanning**: Google Cloud Vision integration for receipt processing
- **Statistics & Analytics**: User spending analytics and dashboard data
- **Security**: Helmet, CORS, rate limiting, and input validation
- **Database**: MongoDB with Mongoose ODM
- **Error Handling**: Comprehensive error handling and logging

## 📋 Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or cloud)
- Plaid API credentials
- Google Cloud Vision API key (optional)

## 🛠️ Installation

1. **Clone the repository and navigate to backend:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

4. **Configure environment variables in `.env`:**
   ```env
   # Server Configuration
   NODE_ENV=development
   PORT=5000
   FRONTEND_URL=http://localhost:3000

   # Database
   MONGODB_URI=mongodb://localhost:27017/spendwise

   # JWT Secret
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

   # Plaid Configuration
   PLAID_CLIENT_ID=your_plaid_client_id
   PLAID_SECRET=your_plaid_secret
   PLAID_ENV=sandbox
   PLAID_REDIRECT_URI=http://localhost:3000/redirect

   # Google Cloud Vision API
   GOOGLE_CLOUD_VISION_API_KEY=your_google_cloud_vision_api_key
   ```

5. **Start the server:**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user profile
- `PUT /api/auth/profile` - Update user profile

### Transactions
- `GET /api/transactions` - Get user transactions (with pagination and filters)
- `POST /api/transactions` - Create a new transaction
- `PUT /api/transactions/:id` - Update a transaction
- `DELETE /api/transactions/:id` - Delete a transaction

### Plaid Integration
- `POST /api/plaid/create_link_token` - Create Plaid link token
- `POST /api/plaid/link` - Link bank account
- `GET /api/plaid/transactions` - Fetch bank transactions
- `POST /api/plaid/cloud-ocr` - Extract text from receipt images

### User Analytics
- `GET /api/users/stats` - Get user spending statistics
- `GET /api/users/dashboard` - Get dashboard data

### Health Check
- `GET /health` - Server health check

## 🔐 Authentication

All protected routes require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## 📊 Database Models

### User
- username, email, password (hashed)
- phone, profile picture
- preferences (currency, language, notifications)
- 2FA settings and backup codes

### Transaction
- amount, category, date, memo
- type (expense/income), payment method
- tags, recurring settings
- attachments

## 🛡️ Security Features

- **Password Hashing**: bcrypt with salt rounds
- **JWT Authentication**: Secure token-based authentication
- **Input Validation**: Express-validator for all inputs
- **Rate Limiting**: Prevents abuse
- **CORS**: Configured for frontend
- **Helmet**: Security headers
- **Error Handling**: No sensitive data in error responses

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch
```

## 📝 Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with nodemon
- `npm test` - Run tests
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## 🔧 Development

### Project Structure
```
backend/
├── config/          # Configuration files
├── controllers/     # Route controllers
├── middleware/      # Custom middleware
├── models/          # Database models
├── routes/          # API routes
├── services/        # Business logic
├── server.js        # Main server file
└── package.json     # Dependencies
```

### Adding New Features

1. **Create Model** (if needed) in `models/`
2. **Create Service** for business logic in `services/`
3. **Create Controller** in `controllers/`
4. **Create Routes** in `routes/`
5. **Add to server.js** if it's a new route group

## 🚀 Deployment

### Environment Variables for Production
- Set `NODE_ENV=production`
- Use strong `JWT_SECRET`
- Configure production `MONGODB_URI`
- Set up proper `FRONTEND_URL`
- Configure Plaid production credentials

### Recommended Hosting
- **Heroku**: Easy deployment with MongoDB Atlas
- **AWS**: EC2 with MongoDB Atlas
- **DigitalOcean**: Droplet with MongoDB
- **Vercel**: Serverless deployment

## 📞 Support

For issues and questions:
1. Check the logs for error details
2. Verify environment variables
3. Test endpoints with Postman/Insomnia
4. Check MongoDB connection

## 🔄 Migration from Old Backend

The new backend is a complete rewrite with:
- Better security and error handling
- Proper authentication system
- Database models and relationships
- Comprehensive API documentation
- Modern development practices

To migrate:
1. Set up the new backend
2. Update frontend API calls to match new endpoints
3. Test all functionality
4. Deploy and switch over













