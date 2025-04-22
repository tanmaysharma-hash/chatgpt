# Use official Node.js 18 Alpine image as base
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Install only production dependencies
COPY package.json ./
RUN yarn install --production --frozen-lockfile

# Copy only necessary source files (excluding dev files via .dockerignore)
COPY . .

# Expose the backend port
EXPOSE 5000

# Use non-root user for security (optional, requires node to own /app)
RUN addgroup app && adduser -S -G app app
USER app

# Start the app
CMD ["node", "server.js"]