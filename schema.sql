-- ============================================================
-- CampusVoice — MySQL Schema
-- Run this in MySQL Workbench before starting the Flask app
-- ============================================================

CREATE DATABASE IF NOT EXISTS campusvoice CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campusvoice;

-- ── Users ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(80)  NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,       -- bcrypt hash
    name         VARCHAR(120) NOT NULL,
    email        VARCHAR(120) UNIQUE,
    role         ENUM('student','admin') NOT NULL DEFAULT 'student',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ── Feedback ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS feedback (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,                          -- NULL = anonymous
    submitter    VARCHAR(120),                 -- display name or 'Anonymous'
    subject      VARCHAR(200) NOT NULL,
    teacher      VARCHAR(120) NOT NULL,
    rating       TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments     TEXT NOT NULL,
    is_anonymous TINYINT(1) DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ── Complaints ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS complaints (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    submitter    VARCHAR(120),
    category     VARCHAR(80)  NOT NULL,
    title        VARCHAR(200) NOT NULL,
    description  TEXT         NOT NULL,
    priority     ENUM('Low','Medium','High') NOT NULL DEFAULT 'Medium',
    status       ENUM('Pending','In Progress','Resolved') NOT NULL DEFAULT 'Pending',
    image_path   VARCHAR(300),                -- relative path to uploaded image
    is_anonymous TINYINT(1) DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ── Seed default admin & two demo students ─────────────────
-- Passwords are bcrypt of: admin123 | pass123
-- You can regenerate these with Python:  bcrypt.generate_password_hash('pass123').decode()
INSERT IGNORE INTO users (username, password, name, email, role) VALUES
('admin',    '$2b$12$eRWZhq3k0IVF2FUPSaXvAuoMHFfL8o4Q3fQjAz8b1P7zW5Mv2I/Oy', 'Administrator',  'admin@campus.edu',   'admin'),
('student1', '$2b$12$YkqDM/HG1F0AYBfU0Ic2BeZ1gH6Kn.Mf3b9VEoXvJb3K5rLd8SvHi', 'Alice Johnson',   'alice@campus.edu',   'student'),
('student2', '$2b$12$YkqDM/HG1F0AYBfU0Ic2BeZ1gH6Kn.Mf3b9VEoXvJb3K5rLd8SvHi', 'Bob Williams',    'bob@campus.edu',     'student');
