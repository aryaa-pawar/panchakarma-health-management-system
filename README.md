# Panchakarma Health Management System

Full-stack clinic management platform for Ayurvedic Panchakarma operations. The repository is structured as a greenfield monorepo with:

- `backend/` - Express API, MySQL schema, JWT auth, RBAC, reporting endpoints
- `frontend/` - React + Vite + Tailwind user interface with role-based dashboards

## Quick Start

### 1. Backend

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

### 2. Frontend

```bash
cd frontend
cp .env.example .env
npm install
npm run dev
```

## Demo Accounts

Seeded passwords use `Password@123` for demo users:

- `admin@panchakarma.local`
- `doctor@panchakarma.local`
- `therapist@panchakarma.local`
- `reception@panchakarma.local`
- `patient@panchakarma.local`

## Delivered Scope

- JWT authentication with RBAC
- Patient, appointment, therapy, package, treatment plan, session, inventory, billing, and report APIs
- MySQL schema with constraints, indexes, views, functions, stored procedures, and triggers
- Role-based dashboards for admin, doctor, therapist, receptionist, and patient
- Public landing page plus patient portal shell
- Demo seed data and API documentation

## Database Objects

The database layer now includes:

- Core normalized tables with foreign keys and check constraints
- Secondary indexes for scheduling, billing, audit, and patient lookups
- Triggers for inventory deduction, bill calculation, payment rollup, and appointment state validation
- Trigger-driven audit logs for patient creation, appointment activity, billing, payments, and therapy sessions
- Stored functions for patient age and bill balance lookup
- Stored procedures for patient registration, appointment booking, session completion, inventory usage, billing, payment posting, patient history, and monthly revenue reporting
- Reporting views for patient summaries, appointment calendar, inventory alerts, billing summary, and doctor performance
- Express controllers now call stored procedures and read from reporting views for core workflows

See `backend/src/db/schema.sql` for the complete MySQL build script.
See `backend/src/db/init_all.sql` for the split-file installer sequence.

## Split SQL Files

The database has also been separated into individual files:

- `backend/src/db/00_database.sql`
- `backend/src/db/01_tables.sql`
- `backend/src/db/02_indexes.sql`
- `backend/src/db/03_functions.sql`
- `backend/src/db/04_procedures.sql`
- `backend/src/db/05_views.sql`
- `backend/src/db/06_triggers.sql`
- `backend/src/db/07_seed_data.sql`
- `backend/src/db/08_demo_queries.sql`
- `backend/src/db/init_all.sql`

Use `init_all.sql` if you want one script that installs the split files in order.

## Run Guide

Detailed step-by-step setup is in `backend/RUN_GUIDE.md`.

## Notes

- Email, SMS, Cloudinary/S3, and online payment gateway integrations are scaffolded conceptually and exposed through service placeholders so they can be connected without redesigning the app.
- The app is intentionally modular: add branch support, WebSockets, or external integrations as feature slices.
