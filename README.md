<p align="center">
  <img src="assets/codexpy-logo.svg" alt="CodexPy" width="420" />
</p>

# CodexPy

**A web-based Python learning platform for school students, university students, and self-learners.**

CodexPy delivers structured Python lessons through learning modules, MCQ quizzes, and progress tracking. Admins manage all content (modules, lessons, quizzes, questions, users) through a dedicated admin panel; learners register, browse modules, read lessons, take quizzes, and track their score history.

Group assignment for **CT050-3-2-WAPP — Web Applications**, Asia Pacific University, Group 12.

---

## Table of Contents

- [Architecture](#architecture)
- [System Requirements](#system-requirements)
- [Dependencies](#dependencies)
- [Setup](#setup)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Create a Supabase project](#2-create-a-supabase-project)
  - [3. Initialize the database schema](#3-initialize-the-database-schema)
  - [4. Configure the connection string](#4-configure-the-connection-string)
  - [5. Open in Visual Studio](#5-open-in-visual-studio)
- [Running the App](#running-the-app)
- [Test Accounts](#test-accounts)
- [Project Layout](#project-layout)
- [Team](#team)
- [License](#license)

---

## Architecture

Single-tier ASP.NET Web Forms application connected directly to a Supabase-hosted PostgreSQL database via the **Npgsql** ADO.NET driver. No middle-tier API — `.aspx` pages render server-side, and code-behind classes (`*.aspx.cs`) execute raw parameterized SQL queries against the database.

```
Browser
   ↓
ASP.NET Web Forms (.aspx + code-behind C#)
   ↓
Npgsql (PostgreSQL wire protocol, SSL)
   ↓
Supabase PostgreSQL (cloud-hosted)
```

Two user roles share the same database:

- **Student** — registers via `/Auth/Register.aspx`, lands on `/User/Dashboard.aspx`. Can browse modules, read lesson content, take MCQ quizzes, view progress, and edit profile.
- **Admin** — promoted from Student via SQL update (see [Test Accounts](#test-accounts)). Lands on `/Admin/Dashboard.aspx`. Has full CRUD on users, modules, lessons, quizzes, and questions, plus a reports page with aggregated SQL analytics.

Authentication uses session-based login with **BCrypt** password hashing. The master pages (`Admin.Master`, `Site.Master`, `Auth.Master`) enforce role-based access gates in their lifecycle events.

---

## System Requirements

| Requirement | Version |
|---|---|
| Visual Studio | 2019 or 2022 (Community edition is fine) |
| Visual Studio workload | **ASP.NET and web development** |
| .NET Framework | 4.7.2 or 4.8 (developer pack) |
| OS | Windows 10 / 11 |
| Internet | Required — the database is hosted on Supabase |

### External services

- **Supabase** — free tier is sufficient. Provides the PostgreSQL database.

---

## Dependencies

NuGet packages (restored automatically on first build via `packages.config`):

- `Npgsql` 8.0.5 — PostgreSQL ADO.NET driver. Lets C# code execute SQL against Supabase.
- `BCrypt.Net-Next` — password hashing/verification.
- `Microsoft.CodeDom.Providers.DotNetCompilerPlatform` — Roslyn compiler for .aspx page compilation.
- Transitive: `System.Memory`, `System.Buffers`, `System.Text.Json`, `System.Threading.Tasks.Extensions`, etc. (pulled in by Npgsql).

No JavaScript build pipeline. No Node.js. No frontend bundler. Styling lives in `Content/site.css` and is referenced directly by master pages.

---

## Setup

### 1. Clone the repository

```powershell
git clone <repo-url> CodexPy
cd CodexPy
```

### 2. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a free account.
2. Click **New Project**.
3. Name it `codexpy`, choose a strong database password (save it — you'll need it in step 4), and pick a region close to your users (Singapore for Southeast Asia).
4. Under **Security**, **uncheck** "Enable Data API" — we connect directly via Npgsql, not the REST API.
5. Click **Create new project** and wait ~2 minutes for provisioning.

### 3. Initialize the database schema

1. In the Supabase dashboard, open the **SQL Editor** from the left sidebar.
2. Click **New query**.
3. Open `schema.sql` from this repo, copy the entire contents, and paste it into the editor.
4. Click **Run** (or press `Ctrl+Enter`).
5. Verify: open **Table Editor** — you should see seven tables (`users`, `modules`, `lessons`, `quizzes`, `questions`, `quiz_attempts`, `user_progress`) and six rows in `modules` (the seed data).

### 4. Configure the connection string

1. In the Supabase dashboard, click **Connect** at the top of the project page (or **Project Settings → Database → Connection string**).
2. Choose the **Session pooler** option (uses IPv4, port 5432) — works on home/school networks. Do not use Direct connection (IPv6).
3. Copy the connection string. It looks like:
   ```
   postgresql://postgres.xxxxxxxx:[YOUR-PASSWORD]@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres
   ```
4. **Convert it to Npgsql key-value format** and put it in `CodexPy/Web.config` under `<connectionStrings>`:
   ```xml
   <connectionStrings>
     <add name="CodexPyDb"
          connectionString="Host=aws-1-ap-southeast-1.pooler.supabase.com;Port=5432;Database=postgres;Username=postgres.xxxxxxxx;Password=YOUR_PASSWORD;SSL Mode=Require;Trust Server Certificate=true"
          providerName="Npgsql" />
   </connectionStrings>
   ```
   Replace `xxxxxxxx` with your project ref and `YOUR_PASSWORD` with the database password from step 2. SSL settings are required — Supabase rejects unencrypted connections.

> `Web.config` contains the live database password. **Do not push this file to a public GitHub repo.** Keep the repo private, or strip the connection string before pushing.

### 5. Open in Visual Studio

1. Double-click `CodexPy.sln` to open the solution.
2. On first open, Visual Studio will restore NuGet packages automatically. If not, right-click the solution → **Restore NuGet Packages**.
3. Press **`Ctrl+Shift+B`** to build. Should succeed with 0 errors.

---

## Running the App

Press **`F5`** in Visual Studio. IIS Express launches and opens your default browser to `https://localhost:<port>/`.

The root URL redirects based on auth state:
- Not logged in → `/Auth/Login.aspx`
- Logged in as Student → `/User/Dashboard.aspx`
- Logged in as Admin → `/Admin/Dashboard.aspx`

### Main routes

**Auth:**
- `/Auth/Register.aspx` — create a new account (defaults to Student role)
- `/Auth/Login.aspx` — sign in
- `/Auth/Logout.aspx` — clears session and redirects to login

**Student-facing (`/User/...`):**
- `Dashboard.aspx` — overview KPIs, continue-learning card, recent scores
- `Modules.aspx` — catalog of all modules, filterable by difficulty
- `ModuleDetail.aspx?id=<n>` — module content (all lessons) + linked quizzes
- `Quiz.aspx?id=<n>` — take an MCQ quiz, get scored, save attempt
- `Profile.aspx` — view/update name, email, segment, password
- `Progress.aspx` — module-by-module progress + quiz history

**Admin-facing (`/Admin/...`):**
- `Dashboard.aspx` — system-wide KPIs
- `Users.aspx` + `UserEdit.aspx` — full CRUD on accounts
- `Modules.aspx` + `ModuleEdit.aspx` — manage learning modules
- `Lessons.aspx?moduleId=<n>` + `LessonEdit.aspx` — manage lessons inside a module
- `Quizzes.aspx` + `QuizEdit.aspx` — manage quiz containers
- `Questions.aspx?quizId=<n>` + `QuestionEdit.aspx` — manage MCQ questions inside a quiz
- `Reports.aspx` — aggregated analytics (audience segments, module engagement, quiz performance, user growth)
- `Profile.aspx` — admin's own profile editor

---

## Test Accounts

The schema does not seed any users — register your own via the Register page on first run.

### Promote a user to Admin

There is no admin sign-up flow (by design). After registering a normal Student account, promote it to Admin via the Supabase SQL Editor:

```sql
UPDATE users SET role = 'Admin' WHERE email = 'your-email@example.com';
```

Log out and log back in to refresh the session role.

---

## Project Layout

```
CodexPy/                              # Solution root
├── CodexPy.sln
├── README.md                         # this file
├── schema.sql                        # database schema for fresh setup
├── .gitignore
└── CodexPy/                          # ASP.NET Web Application project
    ├── CodexPy.csproj
    ├── Web.config                    # connection string + appSettings
    ├── Global.asax
    ├── packages.config               # NuGet manifest
    │
    ├── Content/
    │   └── site.css                  # design tokens + base styles
    │
    ├── Data/
    │   └── DbHelper.cs               # single point for opening Npgsql connections
    │
    ├── MasterPages/
    │   ├── Admin.Master              # admin layout (sidebar with admin nav)
    │   ├── Auth.Master               # login/register layout (no sidebar)
    │   └── Site.Master               # user layout (sidebar with learn nav)
    │
    ├── Auth/
    │   ├── Login.aspx
    │   ├── Register.aspx
    │   └── Logout.aspx
    │
    ├── Admin/                        # admin module (Sonny + Kenneth)
    │   ├── Dashboard.aspx
    │   ├── Users.aspx, UserEdit.aspx
    │   ├── Modules.aspx, ModuleEdit.aspx
    │   ├── Lessons.aspx, LessonEdit.aspx
    │   ├── Quizzes.aspx, QuizEdit.aspx
    │   ├── Questions.aspx, QuestionEdit.aspx
    │   ├── Reports.aspx
    │   └── Profile.aspx
    │
    ├── User/                         # student-facing pages (Darren + Gerald)
    │   ├── Dashboard.aspx
    │   ├── Modules.aspx
    │   ├── ModuleDetail.aspx
    │   ├── Quiz.aspx
    │   ├── Profile.aspx
    │   └── Progress.aspx
    │
    └── Default.aspx                  # root redirector (auth-state-aware)
```

---

## Team

| TP Number | Name | Role |
|---|---|---|
| TP078930 | Kenneth Nathaniel Wong | Group leader, Admin module |
| TP084754 | Sonny Sanputra | Admin module, database integration |
| TP079385 | Darren Daniel Leopold | User module, authentication |
| TP078834 | Gerald Zaklee Oeiyono | User module, authentication |

Lecturer: TS. Muhammad Nur Affendy Bin Nor'A

---

## License

Academic project for CT050-3-2-WAPP at Asia Pacific University. Not licensed for redistribution.
