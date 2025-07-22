# FnF Trading System

A modern full-stack trading system built with FastAPI, Next.js 15 (App Router), PostgreSQL, Redis, and NGINX, containerized with Docker.

## 🚀 Features

- **Backend**: FastAPI with async/await support
- **Frontend**: Next.js 15 with App Router and React 19
- **Database**: PostgreSQL 17 with health monitoring
- **Cache**: Redis 7 with authentication
- **Reverse Proxy**: NGINX with security headers and rate limiting
- **Containerization**: Docker Compose with health checks
- **Real-time Health Monitoring**: Live connection status dashboard
- **Modern UI**: Tailwind CSS with dark theme
- **Security**: CORS, rate limiting, and security headers

## 🏗️ Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   NGINX     │────│  Next.js    │────│  FastAPI    │
│ (Port 80)   │    │ (Port 3000) │    │ (Port 8000) │
└─────────────┘    └─────────────┘    └─────────────┘
                                             │
                          ┌─────────────────┼─────────────────┐
                          │                 │                 │
                   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
                   │ PostgreSQL  │   │   Redis     │   │  FastAPI    │
                   │ (Port 5432) │   │ (Port 6379) │   │  Health     │
                   └─────────────┘   └─────────────┘   └─────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (latest version)
- Docker Compose V2
- Git

### 1. Clone the Repository

```bash
git clone <repository-url>
cd FnFTradingSystem
```

### 2. Environment Setup

Copy the example environment file:

```bash
copy .env.example .env
```

### 3. Run the Application

```bash
docker compose up --build
```

Wait for all services to start (health checks will ensure proper startup order).

### 4. Access the Application

- **Frontend Dashboard**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **NGINX Proxy**: http://localhost (routes to frontend)

## 🔧 Development

### Local Development (without Docker)

#### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Environment Variables

Key environment variables in `.env`:

```env
# Database
DATABASE_URL=postgresql://postgres:postgres123@postgres:5432/trading_db

# Redis
REDIS_URL=redis://redis123@redis:6379

# Security
SECRET_KEY=your-secret-key-change-in-production-2025

# Frontend API URL
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## 📁 Project Structure

```
FnFTradingSystem/
├── backend/                 # FastAPI application
│   ├── app/
│   │   ├── core/           # Configuration and settings
│   │   ├── routers/        # API route handlers
│   │   ├── main.py         # FastAPI application entry point
│   │   ├── database.py     # Database connection and models
│   │   └── redis_client.py # Redis connection
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile         # Backend container definition
│   └── init.sql          # Database initialization
├── frontend/              # Next.js application
│   ├── app/              # Next.js App Router
│   │   ├── layout.tsx    # Root layout
│   │   ├── page.tsx      # Home page with health dashboard
│   │   └── globals.css   # Global styles
│   ├── package.json      # Node.js dependencies
│   ├── Dockerfile        # Frontend container definition
│   └── next.config.js    # Next.js configuration
├── nginx/                # NGINX configuration
│   ├── nginx.conf        # NGINX configuration
│   └── Dockerfile        # NGINX container definition
├── docker-compose.yml    # Docker services orchestration
├── .env.example         # Environment variables template
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## 🔗 API Endpoints

### Health Monitoring
- `GET /api/v1/health` - Comprehensive health check
- `GET /api/v1/health/db` - Database health
- `GET /api/v1/health/redis` - Redis health

### Authentication
- `POST /api/v1/register` - User registration
- `POST /api/v1/login` - User login
- `GET /api/v1/me` - Current user info

### Trading
- `GET /api/v1/positions` - Get trading positions
- `POST /api/v1/positions` - Create new position
- `GET /api/v1/market-data/{symbol}` - Get market data
- `GET /api/v1/symbols` - Available trading symbols

## 🛡️ Security Features

- **CORS**: Configured for frontend domains
- **Rate Limiting**: API and frontend request limits
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Authentication Ready**: JWT token infrastructure
- **Password Protection**: Redis with authentication
- **Database Security**: SCRAM-SHA-256 authentication

## 🔍 Health Monitoring

The system includes comprehensive health monitoring:

- **Real-time Dashboard**: Frontend displays connection status
- **Service Health Checks**: Docker health checks for all services
- **Dependency Management**: Services start in proper order
- **Auto-healing**: Containers restart on failure

## 📈 Performance

- **Async Operations**: FastAPI with async/await
- **Connection Pooling**: Database connection pooling
- **Caching**: Redis for session and data caching
- **Static Asset Optimization**: NGINX with gzip and caching
- **Container Optimization**: Multi-stage Docker builds

## 🚀 Production Deployment

### Environment Configuration

1. Update `.env` with production values:
   ```env
   ENVIRONMENT=production
   DEBUG=false
   SECRET_KEY=your-secure-production-secret-key
   ```

2. Use production-ready database and Redis instances
3. Configure SSL/TLS in NGINX
4. Set up monitoring and logging

### Docker Compose Production

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🧪 Testing

### Run Backend Tests

```bash
cd backend
pytest
```

### Run Frontend Tests

```bash
cd frontend
npm test
```

## 📊 Monitoring and Logs

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres
docker compose logs -f redis
docker compose logs -f nginx
```

### Health Check Status

```bash
docker compose ps
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔧 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 3000, 8000, 5432, 6379 are available
2. **Docker permissions**: Run Docker Desktop as administrator on Windows
3. **Health check failures**: Wait for all services to fully initialize
4. **Database connection issues**: Check PostgreSQL is running and accessible

### Reset Everything

```bash
docker compose down -v
docker system prune -f
docker compose up --build
```

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Built with ❤️ using modern web technologies and best practices for 2025.
