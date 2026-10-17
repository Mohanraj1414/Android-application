# NEXUS People — Enterprise Employee Management System

> **A Production-Grade, Executive-Ready Flutter Application for Enterprise Workforce Management**  
> Designed for presentation to the Managing Director (MD), built with Flutter, Material 3, and SQLite.

---

## 🌟 Executive Overview

**NEXUS People** is an enterprise-tier workforce management system tailored for high-level executive reporting and human resources operations. Built with a cash-flow and headcount-conscious executive mindset, it delivers real-time analytics, responsive multi-factor search and filtering, departmental structure tracking, and persistent SQLite database operations with zero latency.

---

## 🏢 Architectural Highlights

- **Clean Layered Architecture**: Strict segregation between UI Presentation, Domain Models, Repositories, and Data Services.
- **Persistent Local Storage**: Relational SQLite database (`sqflite` with `sqflite_common_ffi` engine) enforcing unique employee IDs, email uniqueness constraints, and transactional activity audit trails.
- **Reactive State Management**: `Provider` architecture with automatic cascading updates across the Executive Dashboard, Directory, Department analytics, and Profile details.
- **Enterprise Design System**:
  - Porcelain & Slate surfaces (`#F8FAFC`, `#FFFFFF`)
  - Deep Navy typography and navigation (`#0F172A`, `#1E293B`)
  - Electric Indigo primary accent (`#4F46E5`)
  - Emerald Green (`#10B981`) for active workforce retention
  - Warm Amber (`#F59E0B`) for leave of absence tracking
  - Coral Red (`#EF4444`) for destructive confirmation states
  - Violet (`#8B5CF6`) for probation and talent pipelines
- **Dynamic Charting**: Vector charts powered by `fl_chart`, dynamically calculated from actual SQLite database timestamps and records (never hardcoded mock values).
- **Responsive Layout System**: Adapts seamlessly between Android phone viewports (one-column cards, drawer, floating action button, bottom bar) and tablet/desktop preview viewports (collapsible corporate sidebar, top header bar, dense data tables).

---

## 📁 Project Directory Structure

```text
lib/
├── main.dart                          # Application entry point with WidgetsFlutterBinding
├── app.dart                           # MultiProvider setup & Material 3 AppTheme bootstrap
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Departments, employment types, statuses, locations
│   ├── theme/
│   │   ├── app_colors.dart            # Enterprise color tokens & elevation shadows
│   │   ├── app_theme.dart             # Material 3 ThemeData (CardThemeData, DialogThemeData, etc.)
│   │   └── app_typography.dart        # Corporate typography scale & tabular metrics
│   └── utils/
│       ├── date_formatter.dart        # Enterprise date formatting, tenure calculator & timeAgo
│       └── validators.dart            # Strict form validations (Name, RFC email, Phone, ID)
├── models/
│   ├── employee.dart                  # Core Employee domain model with SQLite mapping & initials
│   ├── department.dart                # Department metrics, budget, and leadership metadata
│   ├── activity_log.dart              # Executive audit event log model
│   └── dashboard_stats.dart           # Dynamically calculated executive metrics & growth trend
├── services/
│   └── database_service.dart          # Cross-platform SQLite engine with seed data & migrations
├── repositories/
│   └── employee_repository.dart       # CRUD repository, uniqueness checkers & query operations
├── providers/
│   ├── employee_provider.dart         # Main state manager: CRUD, search, multi-factor filtering
│   └── navigation_provider.dart       # Tab navigation and collapsible sidebar state
├── widgets/
│   ├── app_sidebar.dart               # Collapsible desktop/tablet sidebar with MD profile
│   ├── app_top_bar.dart               # Top header with formatted live date & quick CTAs
│   ├── stat_card.dart                 # Executive metric card with icon & trend indicators
│   ├── status_badge.dart              # Status & employment type pill indicators
│   ├── avatar_widget.dart             # Corporate initial badge with live status indicator dot
│   ├── custom_text_field.dart         # Form text field with required indicator & styling
│   ├── employee_card.dart             # Responsive mobile/tablet card with action menu
│   ├── employee_table.dart            # Desktop dense enterprise data table
│   ├── growth_chart.dart              # Line chart showing workforce headcount expansion
│   ├── dept_distribution_chart.dart   # Interactive donut chart with department breakdown
│   └── confirmation_dialog.dart       # Two-step destructive confirmation dialog
└── screens/
    ├── main_layout_screen.dart        # Adaptive shell (Sidebar + Header / Drawer + BottomNav)
    ├── dashboard/
    │   └── dashboard_screen.dart      # Executive dashboard with charts, stats, and audit feed
    ├── employees/
    │   ├── employee_list_screen.dart  # Directory with live search, filters, sorting & views
    │   ├── employee_form_screen.dart  # Form screen for Add Employee and Edit Employee
    │   └── employee_details_screen.dart # Profile screen with contact, tenure & notes
    ├── departments/
    │   └── departments_screen.dart    # Departmental cards with headcount, budget & leads
    └── settings/
        └── settings_screen.dart       # Presentation profile, SQLite diagnostics & demo data reset
```

---

## 🚀 Setup & Execution Guide

### Prerequisites
- Flutter SDK 3.19+ (tested and verified on Flutter 3.47.7 • Dart 3.13.5).
- Android Studio / Android SDK (for Android device or emulator), or Visual Studio / Desktop toolchain for Windows preview.

### Dependencies Installed
- `provider`: State management
- `sqflite`: SQLite database engine
- `sqflite_common_ffi`: Cross-platform SQLite desktop & test runner support
- `fl_chart`: Executive dashboard charts
- `intl`: Date formatting and tenure calculations
- `path` & `path_provider`: Local database path resolution

### Commands

1. **Navigate to the Flutter project folder**:
   ```powershell
   cd "c:\Users\ACER-6\Downloads\first app\flutter_application_1"
   ```

2. **Verify packages and static analysis**:
   ```powershell
   flutter pub get
   dart analyze
   ```
   *(Expected result: No issues found!)*

3. **Run the Automated Test Suite (15 comprehensive unit & widget tests)**:
   ```powershell
   flutter test
   ```
   *(Expected result: All 15 tests passed!)*

4. **Launch the Application**:
   - **On Android Emulator / Device**:
     ```powershell
     flutter run -d android
     ```
   - **On Windows Desktop Preview** (recommended for high-resolution executive presentations):
     ```powershell
     flutter run -d windows
     ```
   - **List available devices**:
     ```powershell
     flutter devices
     ```

---

## 🎬 Managing Director (MD) Demo Walkthrough

When presenting this application to the MD, follow this professional 4-step demonstration flow:

### Step 1: Executive Workforce Dashboard (Read & Analytics)
- Point out the clean executive greeting with current formatted date and administrator mode badge.
- Highlight the **4 KPI Cards**: Total Workforce, Active Employees, Departments, and Recent Additions with trend markers.
- Review the **Workforce Growth Trajectory chart**: note how it computes cumulative headcount from actual joining dates.
- Review the **Department Distribution donut chart**: hover or tap on slices to see headcount and percentage breakdown.
- Inspect the **Live Audit Stream** showing recent hires, role updates, and organizational events.

### Step 2: Employee Directory (Search, Filtering & Sorting)
- Click on **Employees** in the sidebar (or bottom bar on mobile).
- Demonstrate live, instant search by typing a name (e.g. `Jenkins`), department (e.g. `Engineering`), or employee ID (e.g. `NEX-1002`).
- Demonstrate the **Multi-Factor Filters**:
  - Filter by Department: select *Engineering* or *Finance*.
  - Filter by Employment Status: select *Active*, *On Leave*, or *Probation*.
  - Sort by: *Joining Date (Newest)*, *Name (A to Z)*, or *Employee ID*.
- Tap **Clear Filters** to instantly reset the view.

### Step 3: Create & Read Operations
- Click the primary **Add Employee** button in the header.
- Notice the **Auto-Generated Employee ID** (e.g. `NEX-1011`).
- Fill out the form:
  - Name: `Alexander Wright`
  - Email: `alex.wright@nexuscorp.com`
  - Phone: `+1 (415) 555-8833`
  - Department: `Engineering`
  - Designation: `Principal Cloud Architect`
  - Employment Type: `Full-time`, Status: `Active`
  - Location: `San Francisco, CA`
  - Select a corporate avatar color swatch (preview updates live with initials `AW`).
  - Add internal notes regarding enterprise projects.
- Click **Save Employee**: observe the instant SQLite insert, success toast notification, and navigation back.
- Switch back to the **Dashboard**: observe that Total Workforce increased from 10 to 11, the growth chart updated, and the Live Audit Stream logged `Employee Hired: Alexander Wright onboarded to Engineering`.

### Step 4: Update & Delete Operations
- Click on **Alexander Wright** in the directory to open the **Employee Details** screen.
- Review the structured contact card, calculated tenure (`< 1 month`), status badges, and executive notes.
- Click **Edit Profile**: change designation to `VP of Cloud Infrastructure` and click **Update Profile**.
- Back on the profile, verify the updated title.
- Click the red **Delete** button: notice the **Confirmation Dialog** clearly identifying the employee, ID, and department before taking any action.
- Confirm deletion: observe the removal from the local database, toast notification, and dashboard metrics returning to 10 with a logged `Employee Offboarded` audit event.

### Step 5: System Settings & Demo Reset
- Open **Settings**.
- View the database engine statistics (`nexus_people_enterprise.db`).
- Click **Export Summary** to view the executive metrics snapshot.
- Click **Reset Demo Data**: confirms and cleanly re-populates the original 10 demonstration profiles.
