FROM node:20-alpine

# Set the working directory in the docker container
WORKDIR /usr/src/app

# Only copy package.json and package-lock.json initially to leverage Docker cache
COPY package*.json ./

# Install dependencies for production (ignores devDependencies)
RUN npm ci --only=production

# Copy the rest of the application files
COPY . .

# Expose the port the app runs on
EXPOSE 4000

# Define the command to run the application (in production we don't use nodemon)
CMD ["node", "server.js"]
