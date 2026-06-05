-- ===================================================================
-- CodexPy Database Schema
-- Target: Supabase (PostgreSQL 15+)
-- Run this once in the Supabase SQL Editor for a fresh project.
-- ===================================================================

-- Drop tables if re-running (safe for development only).
-- Order: most-dependent first so CASCADE doesn't have to do the work.
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS user_progress CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS modules CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- USERS: students and admins distinguished by `role`
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'Student',
    segment VARCHAR(20) DEFAULT 'University',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMP
);

-- MODULES: learning units (Variables, Functions, OOP, ...)
CREATE TABLE modules (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    blurb TEXT,
    difficulty VARCHAR(20) NOT NULL DEFAULT 'Beginner',
    duration VARCHAR(20),
    color VARCHAR(20) DEFAULT '#3776AB',
    icon VARCHAR(50) DEFAULT 'book',
    sort_order INT NOT NULL DEFAULT 0,
    published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- LESSONS: each module contains one or more lessons
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,
    module_id INT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- QUIZZES: each module can have a quiz
CREATE TABLE quizzes (
    id SERIAL PRIMARY KEY,
    module_id INT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    time_limit_seconds INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- QUESTIONS: quiz items (MCQ with JSON-encoded options array)
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    quiz_id INT NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    kind VARCHAR(20) NOT NULL DEFAULT 'mcq',
    options_json TEXT,
    correct_answer INT,
    starter_code TEXT,
    correct_fill VARCHAR(200),
    explanation TEXT,
    points INT NOT NULL DEFAULT 10,
    sort_order INT NOT NULL DEFAULT 0
);

-- QUIZ ATTEMPTS: records each user's quiz score
CREATE TABLE quiz_attempts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id INT NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    score INT NOT NULL,
    completed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- USER PROGRESS: percent completion per (user, module)
CREATE TABLE user_progress (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_id INT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    progress DECIMAL(3,2) NOT NULL DEFAULT 0,
    last_accessed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, module_id)
);

-- ANNOUNCEMENTS: platform activity feed shown on the User Dashboard.
-- Auto-logged whenever an admin creates / updates / deletes a module, lesson,
-- quiz, or question. See Data/AnnouncementHelper.cs for the write path.
CREATE TABLE announcements (
    id SERIAL PRIMARY KEY,
    action VARCHAR(20) NOT NULL,            -- 'added' | 'updated' | 'removed'
    target_type VARCHAR(20) NOT NULL,       -- 'module' | 'lesson' | 'quiz' | 'question'
    target_name VARCHAR(200) NOT NULL,      -- e.g. "Lists & Dictionaries"
    parent_name VARCHAR(200),               -- e.g. for a lesson: parent module name
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_announcements_created_at ON announcements(created_at DESC);

-- COMMENTS: per-module discussion forum with admin replies.
-- A row with parent_comment_id IS NULL is a top-level student comment.
-- A row with parent_comment_id IS NOT NULL is an admin reply to that comment.
-- is_read marks whether an admin has seen the comment (for the Forum filter).
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_id INT NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    parent_comment_id INT REFERENCES comments(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_comments_module ON comments(module_id);
CREATE INDEX idx_comments_parent ON comments(parent_comment_id);

-- SEED: sample modules so the catalog isn't empty on first run
INSERT INTO modules (title, blurb, difficulty, duration, color, icon, sort_order) VALUES
('Variables and Data Types', 'Strings, integers, floats, booleans — the building blocks.', 'Beginner', '1h 20m', '#3776AB', 'type', 1),
('Control Flow', 'if / elif / else, branching, and ternary expressions.', 'Beginner', '1h 10m', '#10B981', 'bolt', 2),
('Loops & Iteration', 'for, while, break, continue, and comprehensions.', 'Beginner', '55m', '#F59E0B', 'flame', 3),
('Functions', 'Defining functions, arguments, returns, scope, lambda.', 'Beginner', '1h 35m', '#3776AB', 'bolt', 4),
('Lists & Dictionaries', 'Sequences, mappings, slicing, and idiomatic patterns.', 'Intermediate', '1h 25m', '#3776AB', 'folder', 5),
('OOP Basics', 'Classes, instances, inheritance, dunder methods.', 'Intermediate', '2h 10m', '#3776AB', 'shield', 6);
