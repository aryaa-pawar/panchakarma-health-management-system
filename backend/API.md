# API Reference

Base URL: `http://localhost:5000/api`

## Auth

- `POST /auth/register` - register a user
- `POST /auth/login` - login and receive JWT
- `POST /auth/password-reset/request` - request demo OTP
- `GET /auth/me` - current authenticated user

## Patients

- `GET /patients` - list patients
- `GET /patients/:id` - patient profile with timeline and appointments
- `POST /patients` - create patient

## Doctors

- `GET /doctors/treatment-plans` - list treatment plans
- `POST /doctors/treatment-plans` - create treatment plan

## Appointments

- `GET /appointments` - list appointments
- `POST /appointments` - create appointment
- `PATCH /appointments/:id/status` - update appointment status with audit trigger support

## Therapies and Packages

- `GET /therapies`
- `POST /therapies`
- `GET /packages`
- `POST /packages`

## Sessions and Inventory

- `GET /sessions`
- `POST /sessions`
- `POST /sessions/inventory-usage`
- `GET /inventory`
- `POST /inventory`

## Billing and Reports

- `GET /billing/bills`
- `POST /billing/bills/generate`
- `POST /billing/payments`
- `GET /reports/overview`
- `GET /reports/clinic`

## Example Login Payload

```json
{
  "email": "admin@panchakarma.local",
  "password": "Password@123"
}
```
