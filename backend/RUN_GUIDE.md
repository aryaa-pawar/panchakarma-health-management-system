# Run Guide

This guide assumes:

- Windows system
- MySQL 8.x installed
- Node.js 18+ installed
- npm available in terminal

Project root:

- `C:\Users\Arya\Desktop\codex-opd`

## 1. Install prerequisites

Make sure these commands work in PowerShell:

```powershell
node -v
npm -v
mysql --version
```

If `mysql` is not recognized, open **MySQL Command Line Client** or add MySQL `bin` folder to your system PATH.

## 2. Open the project folder

```powershell
cd C:\Users\Arya\Desktop\codex-opd
```

## 3. Install project dependencies

From the project root:

```powershell
npm install
```

## 4. Configure backend environment

```powershell
Copy-Item backend\.env.example backend\.env
```

Open `backend\.env` and set:

- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `JWT_SECRET`
- `CLIENT_URL`

Example:

```env
PORT=5000
CLIENT_URL=http://localhost:5173
JWT_SECRET=super-secret-key
JWT_EXPIRES_IN=12h
DB_HOST=localhost
DB_PORT=3306
DB_NAME=panchakarma_hms
DB_USER=root
DB_PASSWORD=your_mysql_password
```

## 5. Configure frontend environment

```powershell
Copy-Item frontend\.env.example frontend\.env
```

Default frontend API:

```env
VITE_API_URL=http://localhost:5000/api
```

## 6. Create the database

You have 2 ways to do this.

### Option A: Run separate SQL files one by one

```powershell
cd C:\Users\Arya\Desktop\codex-opd\backend\src\db
mysql -u root -p < 00_database.sql
mysql -u root -p panchakarma_hms < 01_tables.sql
mysql -u root -p panchakarma_hms < 02_indexes.sql
mysql -u root -p panchakarma_hms < 03_functions.sql
mysql -u root -p panchakarma_hms < 04_procedures.sql
mysql -u root -p panchakarma_hms < 05_views.sql
mysql -u root -p panchakarma_hms < 06_triggers.sql
mysql -u root -p panchakarma_hms < 07_seed_data.sql
```

This is the best option if you want to show your DBMS project structure clearly.

### Option B: Run the master split installer

Open MySQL shell from the db folder:

```powershell
cd C:\Users\Arya\Desktop\codex-opd\backend\src\db
mysql -u root -p
```

Inside MySQL, run:

```sql
SOURCE init_all.sql;
```

This executes the split files in the correct order.

### Option C: Run the original combined files

If you want the old combined approach:

```powershell
cd C:\Users\Arya\Desktop\codex-opd\backend\src\db
mysql -u root -p < schema.sql
mysql -u root -p < seed.sql
```

## 7. Start the backend server

Open a new PowerShell window:

```powershell
cd C:\Users\Arya\Desktop\codex-opd\backend
npm run dev
```

Expected backend URL:

- `http://localhost:5000/api/health`

You can test it in browser or with:

```powershell
curl http://localhost:5000/api/health
```

## 8. Start the frontend

Open another PowerShell window:

```powershell
cd C:\Users\Arya\Desktop\codex-opd\frontend
npm run dev
```

Expected frontend URL:

- `http://localhost:5173`

## 9. Login with demo users

Password for all seeded users:

- `Password@123`

Demo accounts:

- `admin@panchakarma.local`
- `doctor@panchakarma.local`
- `therapist@panchakarma.local`
- `reception@panchakarma.local`
- `patient@panchakarma.local`

## 10. Run demo DBMS queries

After database setup:

```powershell
cd C:\Users\Arya\Desktop\codex-opd\backend\src\db
mysql -u root -p panchakarma_hms < 08_demo_queries.sql
```

That runs:

- stored procedures
- views
- functions

## Recommended submission structure

For a DBMS project presentation, show the files in this order:

1. `00_database.sql`
2. `01_tables.sql`
3. `02_indexes.sql`
4. `03_functions.sql`
5. `04_procedures.sql`
6. `05_views.sql`
7. `06_triggers.sql`
8. `07_seed_data.sql`
9. `08_demo_queries.sql`

## If something fails

Common fixes:

- If MySQL says `Access denied`, check `DB_USER` and `DB_PASSWORD`
- If `mysql` command is not found, use MySQL Command Line Client or fix PATH
- If backend cannot connect, verify MySQL service is running
- If frontend shows network errors, confirm backend is running on port `5000`
- If login fails, rerun `07_seed_data.sql` after recreating the database
