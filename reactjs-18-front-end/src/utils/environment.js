/**
 * Client-side Environment Configuration Utility
 * Dynamically resolves API endpoints and handles CORS-compatible hostnames
 */

class ClientEnvironmentConfig {
  constructor() {
    this.hostname = this.getHostname();
    this.protocol = this.getProtocol();
  }

  /**
   * Get current hostname from browser
   */
  getHostname() {
    if (typeof window !== 'undefined') {
      return window.location.hostname;
    }
    return 'localhost';
  }

  /**
   * Get current protocol
   */
  getProtocol() {
    if (typeof window !== 'undefined') {
      return window.location.protocol;
    }
    return 'http:';
  }

  /**
   * Get API base URL dynamically
   */
  getAPIBaseURL() {
    // First check if explicitly set in environment
    if (process.env.REACT_APP_API_URL) {
      // If it's not localhost, use as-is
      if (!process.env.REACT_APP_API_URL.includes('localhost')) {
        return process.env.REACT_APP_API_URL;
      }
    }

    // For development, check if we should use a different hostname
    const apiHost = process.env.REACT_APP_API_HOST || this.hostname;
    const apiPort = process.env.REACT_APP_API_PORT || '5000';
    const apiProtocol = process.env.REACT_APP_API_PROTOCOL || this.protocol;

    return `${apiProtocol}//${apiHost}:${apiPort}/api`;
  }

  /**
   * Get Swagger UI URL dynamically
   */
  getSwaggerUIURL() {
    const swaggerHost = process.env.REACT_APP_SWAGGER_HOST || this.hostname;
    const swaggerPort = process.env.REACT_APP_SWAGGER_PORT || '8080';
    const swaggerProtocol = process.env.REACT_APP_SWAGGER_PROTOCOL || this.protocol;

    return `${swaggerProtocol}//${swaggerHost}:${swaggerPort}/swagger-ui.html`;
  }

  /**
   * Get complete configuration
   */
  getConfig() {
    return {
      hostname: this.hostname,
      protocol: this.protocol,
      api: {
        baseURL: this.getAPIBaseURL(),
        host: process.env.REACT_APP_API_HOST || this.hostname,
        port: process.env.REACT_APP_API_PORT || '5000',
        protocol: process.env.REACT_APP_API_PROTOCOL || this.protocol
      },
      swagger: {
        url: this.getSwaggerUIURL(),
        host: process.env.REACT_APP_SWAGGER_HOST || this.hostname,
        port: process.env.REACT_APP_SWAGGER_PORT || '8080',
        protocol: process.env.REACT_APP_SWAGGER_PROTOCOL || this.protocol
      }
    };
  }

  /**
   * Test API connectivity
   */
  async testAPIConnection() {
    const apiURL = this.getAPIBaseURL();
    try {
      const response = await fetch(`${apiURL}/todos/stats`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (response.ok) {
        return { success: true, url: apiURL, status: response.status };
      } else {
        return { success: false, url: apiURL, status: response.status, error: 'HTTP Error' };
      }
    } catch (error) {
      return { success: false, url: apiURL, error: error.message };
    }
  }

  /**
   * Print configuration to console (for debugging)
   */
  printConfig() {
    const config = this.getConfig();
    console.log('🌐 Client Environment Configuration:', config);
    return config;
  }
}

// Create singleton instance
const clientEnvConfig = new ClientEnvironmentConfig();

// Export both class and instance
export {
  ClientEnvironmentConfig,
  clientEnvConfig
};

// Default export for convenience
export default {
  getAPIBaseURL: () => clientEnvConfig.getAPIBaseURL(),
  getSwaggerUIURL: () => clientEnvConfig.getSwaggerUIURL(),
  getConfig: () => clientEnvConfig.getConfig(),
  testAPIConnection: () => clientEnvConfig.testAPIConnection(),
  printConfig: () => clientEnvConfig.printConfig()
};