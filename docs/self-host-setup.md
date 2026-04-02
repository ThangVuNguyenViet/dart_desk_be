# Self-Hosting Dart Desk

This guide walks you through setting up Dart Desk on your own infrastructure.

## Prerequisites

- PostgreSQL 15+
- Dart SDK 3.x
- A running instance of `dart_desk_server`

## 1. Configure the Server

Copy and edit the config files:

```bash
cp config/development.yaml config/production.yaml
cp config/passwords.yaml.example config/passwords.yaml  # or use env vars
```

Set your database, Redis, and JWT secrets in `passwords.yaml` or via environment variables (see `SERVERPOD_PASSWORD_*` in Serverpod docs).

> **Note:** Do NOT set `cloudAdminKey` — that is reserved for the managed cloud service.

## 2. Start the Server

```bash
dart bin/main.dart --mode production --apply-migrations
```

The server starts on port 8080 by default.

## 3. Create Your Account

Sign up using the Email identity provider. All API calls below use the server's base URL (e.g. `http://localhost:8080`).

### 3a. Register

```
POST /emailIdp/registerWithEmail
Content-Type: application/json

{
  "email": "you@example.com",
  "password": "your-secure-password"
}
```

A verification code will be printed to the server logs. Use it to verify:

```
POST /emailIdp/verifyRegistration
Content-Type: application/json

{
  "email": "you@example.com",
  "verificationCode": "<code from server logs>"
}
```

### 3b. Sign In

```
POST /emailIdp/signInWithEmail
Content-Type: application/json

{
  "email": "you@example.com",
  "password": "your-secure-password"
}
```

This returns a JWT token. Use it as `Authorization: Bearer <token>` for subsequent requests.

## 4. Create Your Workspace

```
POST /project/createClientWithOwner
Authorization: Bearer <token>
Content-Type: application/json

{
  "clientName": "My Company",
  "clientSlug": "my-company"
}
```

This creates your workspace (CmsClient) and your admin User in one step.

## 5. Create a Project

```
POST /project/createProject
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "My Website",
  "slug": "my-website"
}
```

Note the returned project `id`.

## 6. Generate an API Key

```
POST /apiToken/createToken
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "my-dev-key",
  "role": "write",
  "expiresAt": null,
  "projectId": <project-id>
}
```

The response includes `plaintextToken` — **save it now**, it is only shown once.

## 7. Connect the Dart Desk App

In the Dart Desk Flutter app, enter:

- **Server URL:** your server's base URL
- **API Key:** the plaintext token from step 6

You're ready to go.

## Adding More Users

Additional users follow the same flow (steps 3-6). Each user can create their own workspace, or you can build invite functionality as needed.
