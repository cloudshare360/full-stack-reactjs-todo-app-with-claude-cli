const os = require('os');

/**
 * Environment Configuration Utility
 * Dynamically resolves hostnames and provides environment-specific configurations
 */
class EnvironmentConfig {
  constructor() {
    this.hostname = this.getHostname();
    this.ipAddress = this.getLocalIPAddress();
    this.environment = process.env.NODE_ENV || 'development';
  }

  /**
   * Get the current hostname
   */
  getHostname() {
    return process.env.HOST_NAME || os.hostname();
  }

  /**
   * Get the local IP address (first non-internal IPv4 address)
   */
  getLocalIPAddress() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
      for (const iface of interfaces[name]) {
        if (iface.family === 'IPv4' && !iface.internal) {
          return iface.address;
        }
      }
    }
    return '127.0.0.1'; // fallback to localhost
  }

  /**
   * Get MongoDB connection URI with dynamic hostname
   */
  getMongoDBURI() {
    const host = process.env.MONGODB_HOST || this.hostname || 'localhost';
    const port = process.env.MONGODB_PORT || '27017';
    const database = process.env.MONGODB_DATABASE || 'todoapp';
    const username = process.env.MONGODB_USERNAME || 'todouser';
    const password = process.env.MONGODB_PASSWORD || 'todopass123';

    // If running in production or a specific MongoDB URI is provided, use that
    if (process.env.MONGODB_URI) {
      return process.env.MONGODB_URI;
    }

    // Build dynamic URI
    return `mongodb://${username}:${password}@${host}:${port}/${database}`;
  }

  /**
   * Get API base URL with dynamic hostname
   */
  getAPIBaseURL() {
    const protocol = process.env.API_PROTOCOL || 'http';
    const host = process.env.API_HOST || this.getAPIHost();
    const port = process.env.API_PORT || process.env.PORT || '5000';

    return `${protocol}://${host}:${port}`;
  }

  /**
   * Get API host - prefer explicit configuration, then IP, then hostname
   */
  getAPIHost() {
    if (process.env.API_HOST) {
      return process.env.API_HOST;
    }

    // In development, prefer localhost for simplicity
    if (this.environment === 'development') {
      return 'localhost';
    }

    // In production, use the local IP address or hostname
    return this.ipAddress !== '127.0.0.1' ? this.ipAddress : this.hostname;
  }

  /**
   * Get frontend URL with dynamic hostname
   */
  getFrontendURL() {
    const protocol = process.env.FRONTEND_PROTOCOL || 'http';
    const host = process.env.FRONTEND_HOST || this.getFrontendHost();
    const port = process.env.FRONTEND_PORT || '3000';

    return `${protocol}://${host}:${port}`;
  }

  /**
   * Get frontend host
   */
  getFrontendHost() {
    if (process.env.FRONTEND_HOST) {
      return process.env.FRONTEND_HOST;
    }

    return this.getAPIHost(); // Same logic as API host
  }

  /**
   * Get all allowed CORS origins
   */
  getCORSOrigins() {
    // If explicitly set, use those
    if (process.env.CORS_ORIGINS) {
      return process.env.CORS_ORIGINS.split(',').map(origin => origin.trim());
    }

    const origins = [];

    // Development origins
    if (this.environment === 'development') {
      origins.push(
        'http://localhost:3000',
        'http://localhost:3001',
        'http://localhost:4200', // Angular default
        'http://localhost:8080', // Swagger UI
        'http://127.0.0.1:3000',
        'http://127.0.0.1:3001',
        'http://127.0.0.1:4200',
        'http://127.0.0.1:8080'
      );
    }

    // Add hostname-based origins
    const hostVariants = [this.hostname, this.ipAddress];
    const ports = ['3000', '3001', '4200', '8080'];

    for (const host of hostVariants) {
      for (const port of ports) {
        origins.push(`http://${host}:${port}`);
        origins.push(`https://${host}:${port}`);
      }
    }

    // Remove duplicates
    return [...new Set(origins)];
  }

  /**
   * Get complete configuration object
   */
  getConfig() {
    return {
      environment: this.environment,
      hostname: this.hostname,
      ipAddress: this.ipAddress,
      mongodb: {
        uri: this.getMongoDBURI(),
        host: process.env.MONGODB_HOST || this.hostname || 'localhost',
        port: process.env.MONGODB_PORT || '27017',
        database: process.env.MONGODB_DATABASE || 'todoapp'
      },
      api: {
        protocol: process.env.API_PROTOCOL || 'http',
        host: this.getAPIHost(),
        port: process.env.API_PORT || process.env.PORT || '5000',
        baseURL: this.getAPIBaseURL()
      },
      frontend: {
        protocol: process.env.FRONTEND_PROTOCOL || 'http',
        host: this.getFrontendHost(),
        port: process.env.FRONTEND_PORT || '3000',
        baseURL: this.getFrontendURL()
      },
      cors: {
        origins: this.getCORSOrigins()
      }
    };
  }

  /**
   * Print current configuration
   */
  printConfig() {
    const config = this.getConfig();
    console.log(`
🌐 Environment Configuration:
────────────────────────────────
📊 Environment: ${config.environment}
🖥️  Hostname: ${config.hostname}
🌍 IP Address: ${config.ipAddress}

🗄️  MongoDB:
   📍 URI: ${config.mongodb.uri}

🚀 API Server:
   📍 Base URL: ${config.api.baseURL}
   🌍 Host: ${config.api.host}
   🔌 Port: ${config.api.port}

🎨 Frontend:
   📍 Base URL: ${config.frontend.baseURL}
   🌍 Host: ${config.frontend.host}
   🔌 Port: ${config.frontend.port}

🔐 CORS Origins:
${config.cors.origins.map(origin => `   ✅ ${origin}`).join('\n')}
────────────────────────────────
`);
  }
}

// Create singleton instance
const envConfig = new EnvironmentConfig();

// Export both the class and the instance
module.exports = {
  EnvironmentConfig,
  envConfig,
  // Convenience exports
  getConfig: () => envConfig.getConfig(),
  getAPIBaseURL: () => envConfig.getAPIBaseURL(),
  getFrontendURL: () => envConfig.getFrontendURL(),
  getMongoDBURI: () => envConfig.getMongoDBURI(),
  getCORSOrigins: () => envConfig.getCORSOrigins(),
  printConfig: () => envConfig.printConfig()
};