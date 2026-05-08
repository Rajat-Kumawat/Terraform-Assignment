FROM node:16-slim

# Create app directory
WORKDIR /app

# Initialize a package.json and install express
RUN npm init -y && npm install express

# Copy your code
COPY index.js .

# Expose port 3000
EXPOSE 3000

CMD ["node", "index.js"]