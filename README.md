# CampusVoice — Flask + MySQL Setup Guide

## Project Structure

```
campusvoice/
├── app.py                  ← Flask app factory & extension init
├── models.py               ← User model (Flask-Login)
├── requirements.txt        ← Python dependencies
├── schema.sql              ← MySQL database schema + seed data
├── routes/
│   ├── __init__.py
│   ├── main.py             ← Serves the HTML shell
│   ├── auth.py             ← /api/auth/* (login, register, logout, me)
│   ├── feedback.py         ← /api/feedback/* (submit, my, all, delete)
│   ├── complaints.py       ← /api/complaints/* (submit, my, all, status, delete)
│   └── admin.py            ← /api/admin/* (users, analytics, dashboard)
├── templates/
│   └── index.html          ← Single-page app HTML (same UI as original)
└── static/
    ├── css/
    │   └── style.css       ← All CSS extracted from original
    ├── js/
    │   └── app.js          ← Frontend JS (API calls instead of localStorage)
    └── uploads/            ← Uploaded complaint images (auto-created)
```

---

## Step 1 — MySQL Workbench Setup

1. Open **MySQL Workbench** and connect to your local MySQL server.
2. Open a new SQL tab and paste the contents of `schema.sql`.
3. Run the script (⚡ or Ctrl+Shift+Enter).
4. This creates the `campusvoice` database with tables: `users`, `feedback`, `complaints`.
5. Three seed accounts are inserted automatically:
   - Admin: `admin` / `admin123`
   - Student 1: `student1` / `pass123`
   - Student 2: `student2` / `pass123`

---

## Step 2 — Configure MySQL Password

Open `app.py` and update the database credentials:

```python
app.config['MYSQL_USER']     = 'root'          # your MySQL username
app.config['MYSQL_PASSWORD'] = 'your_password' # your MySQL password
app.config['MYSQL_DB']       = 'campusvoice'
```

Or use environment variables (recommended):

```bash
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
```

---

## Step 3 — Install Python Dependencies

```bash
# Create a virtual environment (recommended)
python -m venv venv
source venv/bin/activate        # Mac/Linux
venv\Scripts\activate           # Windows

# Install packages
pip install -r requirements.txt
```

> **Windows users:** If `mysqlclient` fails, install it via:
> ```
> pip install mysqlclient --only-binary=mysqlclient
> ```
> Or use `PyMySQL` as an alternative (add `import pymysql; pymysql.install_as_MySQLdb()` at top of `app.py`).

---

## Step 4 — Run the App

```bash
python app.py
```

Open your browser at: **http://localhost:5000**

---

## API Endpoints Reference

### Auth  (`/api/auth`)
| Method | Endpoint        | Description              |
|--------|-----------------|--------------------------|
| POST   | `/register`     | Create new account       |
| POST   | `/login`        | Sign in                  |
| POST   | `/logout`       | Sign out                 |
| GET    | `/me`           | Get current user session |

### Feedback  (`/api/feedback`)
| Method | Endpoint   | Auth       | Description            |
|--------|------------|------------|------------------------|
| POST   | `/submit`  | Student    | Submit feedback        |
| GET    | `/my`      | Student    | My feedback list       |
| GET    | `/all`     | Admin only | All feedback + filters |
| DELETE | `/<id>`    | Admin only | Delete a feedback      |

### Complaints  (`/api/complaints`)
| Method | Endpoint         | Auth       | Description              |
|--------|------------------|------------|--------------------------|
| POST   | `/submit`        | Student    | File complaint + image   |
| GET    | `/my`            | Student    | My complaints            |
| GET    | `/all`           | Admin only | All complaints + filters |
| PATCH  | `/<id>/status`   | Admin only | Update status            |
| DELETE | `/<id>`          | Admin only | Delete complaint         |

### Admin  (`/api/admin`)
| Method | Endpoint       | Description              |
|--------|----------------|--------------------------|
| GET    | `/dashboard`   | Summary stats + recent   |
| GET    | `/analytics`   | Chart data (aggregates)  |
| GET    | `/users`       | List all users           |
| DELETE | `/users/<id>`  | Remove a user            |

---

## Features

- **Student:** Register/Login, Submit Feedback (with star rating), File Complaints (with image upload, category, priority), View own submissions, Anonymous submissions
- **Admin:** View all feedback & complaints, Filter/search, Update complaint status (Pending → In Progress → Resolved), Analytics with 4 live charts (Chart.js), User management
- **Security:** Passwords hashed with bcrypt, Session-based auth via Flask-Login, Admin-only routes protected server-side
