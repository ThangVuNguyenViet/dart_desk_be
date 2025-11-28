# Serverpod Installation & Getting Started

## What is Serverpod?

Serverpod is an open-source backend framework for Flutter applications written in Dart. It streamlines backend development by minimizing boilerplate code and incorporating numerous built-in capabilities for server-side operations.

## Prerequisites

Before installing Serverpod, ensure you have:
- Flutter SDK installed
- PostgreSQL access (Docker recommended)
- Dart SDK (comes with Flutter)

## Installation Steps

### 1. Install Serverpod CLI

```bash
dart pub global activate serverpod_cli
```

### 2. Create a New Project

```bash
serverpod create <project_name>
```

This generates three main directories:
- **Server**: Backend server code
- **Client**: Generated client library
- **Flutter**: Example Flutter application

### 3. Start PostgreSQL Database

```bash
cd <project_name>/server
docker compose up -d
```

### 4. Run Database Migrations

```bash
cd <project_name>/server
dart bin/main.dart --apply-migrations
```

### 5. Start the Server

```bash
dart bin/main.dart
```

The server will start on:
- **Port 8080**: Client connections
- **Port 8081**: Serverpod Insights (development tools)
- **Port 8082**: Built-in web server

## Key Features

### Code Generation
Serverpod automatically generates client-side Dart APIs and data classes from server code, making remote calls feel like local method invocations.

### Database Integration
Built-in ORM with PostgreSQL support allows developers to write Dart instead of SQL. The system includes automatic migrations to keep schema changes versioned and synchronized.

### Caching & Performance
High-performance, distributed caching is included, supporting in-memory storage or Redis distribution.

### Authentication
User authentication comes ready out-of-the-box, with support for:
- Google Sign-In
- Apple Sign-In
- Firebase Auth
- Email/Password

### Real-time Features
WebSocket-enabled Dart streams enable live data updates for applications requiring immediate communication.

### Deployment
- **Serverpod Cloud**: Zero-configuration deployment (currently in private beta)
- **Docker**: Community Terraform scripts and Docker support
- **Manual**: Deploy on any platform supported by Dart

## Project Structure

```
project_name/
├── server/           # Backend server code
│   ├── lib/
│   │   ├── src/
│   │   │   ├── endpoints/    # API endpoints
│   │   │   ├── generated/    # Auto-generated code
│   │   └── server.dart
│   ├── config/
│   │   ├── development.yaml
│   │   ├── production.yaml
│   │   └── passwords.yaml
│   └── bin/
│       └── main.dart
├── client/           # Generated client library
└── flutter/          # Example Flutter app
```

## Basic Workflow

1. **Define Models**: Create `.spy.yaml` files in `server/lib/`
2. **Create Endpoints**: Add endpoint classes extending `Endpoint`
3. **Generate Code**: Run `serverpod generate` in server directory
4. **Apply Migrations**: Run `serverpod create-migration` and apply migrations
5. **Use in Flutter**: Import generated client library in your Flutter app

## Health Check

The server exposes a health check endpoint at:
```
http://localhost:8080/
```

This allows load balancers and monitoring systems to verify operational status.

## Configuration Files

### Development Configuration (`config/development.yaml`)
Contains settings for local development environment.

### Production Configuration (`config/production.yaml`)
Must configure database connectivity for production deployment.

### Passwords (`config/passwords.yaml`)
Securely stores sensitive credentials - must be deployed separately.

## Next Steps

After installation:
1. Create your first endpoint
2. Define data models
3. Set up database tables
4. Implement authentication
5. Deploy to production

## Resources

- **Official Documentation**: https://docs.serverpod.dev/
- **API Reference**: https://pub.dev/documentation/serverpod/latest/
- **GitHub**: https://github.com/serverpod/serverpod
- **Serverpod Academy**: https://docs.serverpod.dev/tutorials/academy
