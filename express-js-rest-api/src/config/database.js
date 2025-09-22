const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Validate MONGODB_URI exists
    if (!process.env.MONGODB_URI) {
      throw new Error('MONGODB_URI environment variable is required');
    }

    console.log('🔌 Connecting to MongoDB...');
    console.log(`📍 Database URI: ${process.env.MONGODB_URI.replace(/\/\/.*@/, '//***:***@')}`);

    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      // Modern connection options
      serverSelectionTimeoutMS: 5000, // Keep trying to send operations for 5 seconds
      socketTimeoutMS: 45000, // Close sockets after 45 seconds of inactivity
      maxPoolSize: 10, // Maintain up to 10 socket connections
      serverApi: '1'
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database: ${conn.connection.name}`);
    console.log(`🔧 Connection ready state: ${conn.connection.readyState}`);

    // Handle connection events
    mongoose.connection.on('connected', () => {
      console.log('🟢 Mongoose connected to MongoDB');
    });

    mongoose.connection.on('error', (err) => {
      console.error('🔴 Mongoose connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('🟡 Mongoose disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      console.log('🔵 Mongoose reconnected to MongoDB');
    });

    // Graceful shutdown
    process.on('SIGINT', async () => {
      console.log('\n🛑 Received SIGINT, shutting down gracefully...');
      await mongoose.connection.close();
      console.log('🔌 MongoDB connection closed through app termination');
      process.exit(0);
    });

  } catch (error) {
    console.error('❌ Error connecting to MongoDB:', error.message);
    
    if (process.env.NODE_ENV === 'development') {
      console.log('\n🔧 Development Debug Info:');
      console.log('- Make sure MongoDB is running (Docker or local)');
      console.log('- Check if MONGODB_URI is correct in .env file');
      console.log('- Current MONGODB_URI:', process.env.MONGODB_URI || 'NOT SET');
      console.log('\n💡 Try running: npm run start:mongo (if using Docker setup)');
    }
    
    process.exit(1);
  }
};

module.exports = connectDB;