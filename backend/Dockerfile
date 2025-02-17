# Use official Node.js 18 Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json .

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy all backend files
COPY . .

# Expose application port
EXPOSE 5000

# Start the application
CMD ["node", "server.js"]