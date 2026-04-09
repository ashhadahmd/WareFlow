# WareFlow - Warehouse Management System

WareFlow is a modern, full-stack Warehouse Management System designed for multi-tenant environments. It allows organizations to effortlessly manage their inventory, suppliers, orders, and teams with granular permissions, real-time analytics, and a beautiful sleek interface.

## Key Features

- **Multi-Tenancy (Warehouses):** Create or join multiple independent warehouses like a Slack-style workspace.
- **Granular Permissions:** Give users targeted access like `inventory:write` or `orders:manage`.
- **Email Invitations:** Easily onboard your team with secure one-time invite links. 
- **Inventory Management:** Track stock levels, low-stock alerts, and item details.
- **Supplier & Order Tracking:** Track inbound and outbound orders that automatically update stock quantities upon completion.
- **Sleek UI/UX:** A visually stunning Glassmorphism design system built with Next.js App Router and Tailwind CSS, featuring full Light and Dark mode support.

## Tech Stack

- **Frontend:** Next.js 15+, React, Tailwind CSS V4, Recharts, Lucide Icons
- **Backend:** Python, FastAPI, SQLAlchemy
- **Database:** PostgreSQL
- **Package Manager:** `uv` (for Python)

---

## Running the Application Locally

### 1. Database Setup
Ensure you have PostgreSQL installed and running locally. The application defaults to using `postgresql://postgres:postgres@localhost:5432/wareflow`.

### 1.1 Environment Variables
Copy [backend/example.env](backend/example.env) to [backend/.env](backend/.env) and update the values if needed.

### 2. Backend (FastAPI)

Ensure you have `uv` package manager installed.

```bash
cd backend

# Install dependencies using uv
uv pip install -r requirements.txt

# Run the seeding script to create the tables, inject test data, and configure the default users
uv run python seed.py

# Start the FastAPI backend server
uv run uvicorn app.main:app --reload --port 8000
```
The backend API and Swagger Docs will be available at `http://localhost:8000/docs`.

### 3. Frontend (Next.js)

```bash
cd frontend

# Install Node.js dependencies
npm install

# Start the Next.js development server
npm run dev
```
The frontend web application will be available at `http://localhost:3000`.

### Default Login
If you ran the seed script, you can log in immediately:
- **Email:** `admin@wareflow.com`
- **Password:** `admin123`
