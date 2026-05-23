# Qubah Learning App - Independent Laravel Backend Architecture

This document outlines the architecture, database schema, and API design for the standalone Laravel backend serving the Qubah Learning App (and potentially other clients).

## 🏛️ Architecture Overview

The backend is designed following Clean Architecture principles and a Domain-Driven approach within Laravel's structure. It ensures strict separation from any client implementation.

### Folder Structure

We will use the standard Laravel structure with specific layers for business logic:

```text
app/
├── Http/
│   ├── Controllers/
│   │   ├── Api/v1/          # Client API Controllers (Thin)
│   │   └── Auth/            # Auth Controllers
│   ├── Middleware/          # Custom middleware (Role checks, etc.)
│   ├── Requests/            # Form Requests (Validation)
│   └── Resources/           # API Resources (Data transformation/DTOs)
├── Models/                  # Eloquent Models & Relationships
├── Services/                # Business Logic Layer
├── Repositories/            # Data Access Abstraction (Optional, used where needed)
├── Actions/                 # Single-action classes for complex operations
├── Enums/                   # Enums for Roles, Content Types, etc.
├── Filament/                # Admin Panel Resources & Pages
├── Notifications/           # Mail and system notifications
└── Jobs/                    # Background tasks (Queues)
```

## 🗄️ Database Schema

The schema is designed to support an educational platform with users, subjects, topics, and various content types.

### Tables

#### 1. `users`
- `id` (PK)
- `name` (string)
- `email` (string, unique)
- `password` (string)
- `role` (enum: `admin`, `parent`, `student`)
- `email_verified_at` (timestamp, nullable)
- `remember_token` (string, nullable)
- `timestamps`

#### 2. `subjects`
- `id` (PK)
- `title` (string)
- `description` (text, nullable)
- `thumbnail_url` (string, nullable)
- `is_active` (boolean, default: true)
- `timestamps`
- `soft_deletes`

#### 3. `topics`
- `id` (PK)
- `subject_id` (FK -> subjects.id)
- `title` (string)
- `description` (text, nullable)
- `order` (integer, default: 0)
- `timestamps`
- `soft_deletes`

#### 4. `contents`
- `id` (PK)
- `topic_id` (FK -> topics.id)
- `title` (string)
- `type` (enum: `video`, `audio`, `pdf`, `interactive`)
- `file_path` (string, nullable) - For local/S3 storage
- `url` (string, nullable) - For external links
- `metadata` (json, nullable) - For SCORM or specific content details
- `order` (integer, default: 0)
- `timestamps`
- `soft_deletes`

#### 5. `user_progress`
- `id` (PK)
- `user_id` (FK -> users.id)
- `content_id` (FK -> contents.id)
- `status` (enum: `started`, `completed`)
- `time_spent` (integer) - In seconds
- `score` (integer, nullable) - For quizzes or interactive content
- `timestamps`

#### 6. `parent_child`
- `id` (PK)
- `parent_id` (FK -> users.id)
- `child_id` (FK -> users.id)
- `timestamps`

## 📡 API Routes (RESTful)

All client-facing endpoints will be under `/api/v1/` and return consistent JSON responses.

### Authentication
- `POST /api/v1/auth/register` (Parent or Student self-registration if allowed)
- `POST /api/v1/auth/login` -> Returns Sanctum Token
- `POST /api/v1/auth/logout` (Protected)
- `POST /api/v1/auth/password/forgot`
- `POST /api/v1/auth/password/reset`

### Subjects & Content (Protected)
- `GET /api/v1/subjects` -> List all active subjects
- `GET /api/v1/subjects/{id}` -> Get subject with topics
- `GET /api/v1/topics/{id}` -> Get topic with contents
- `GET /api/v1/contents/{id}` -> Get specific content details

### Progress Tracking (Protected)
- `POST /api/v1/progress` -> Update user progress
- `GET /api/v1/progress/summary` -> Get user's learning summary

### Parent Dashboard (Protected, Role: Parent)
- `GET /api/v1/parent/children` -> List linked children
- `GET /api/v1/parent/children/{id}/progress` -> Get specific child's progress

## 🧩 Admin Panel (Filament)

Filament will be used to manage:
- **User Management**: Admins can manage users, assign roles, and link parents to children.
- **Content Management**: Upload and manage subjects, topics, and contents (videos, PDFs, interactive packages).
- **System Monitoring**: View logs and progress summaries.

## 🔒 Security Measures

- **Laravel Sanctum**: Token-based authentication for all API requests.
- **Rate Limiting**: Applied to auth and sensitive endpoints.
- **Form Requests**: Strict validation on all incoming data.
- **CORS**: Configured to allow requests only from trusted origins (or open for mobile clients as needed).

---
> [!IMPORTANT]
> This architecture ensures that the backend is a standalone system. The Flutter app will interact with it solely through these API endpoints.
