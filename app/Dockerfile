FROM node:18-alpine

WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund

# Copy the rest
COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["npm", "start"]