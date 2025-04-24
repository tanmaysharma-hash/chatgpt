# Step 1: Use Node Alpine as the base image
FROM node:18-alpine

# Step 2: Set working directo/appry inside the container
WORKDIR /app

# Step 3: Install dependencies by copying package.json and package-lock.json
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

# Step 4: Copy the rest of the code into the container
COPY . .

# Step 5: Expose port 3000 for React development server
EXPOSE 3000

# Use non-root user for security (optional, requires node to own /app)
#RUN addgroup app && adduser -S -G app app
#USER app

# Step 6: Start the React app using npm
CMD ["npm", "start"]