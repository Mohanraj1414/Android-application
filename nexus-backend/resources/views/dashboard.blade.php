<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NEXUS People - Enterprise Directory</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-page: #0f172a;
            --bg-card: #1e293b;
            --bg-card-hover: #24344d;
            --border: #334155;
            --text-primary: #f8fafc;
            --text-muted: #94a3b8;
            --accent: #6366f1;
            --accent-hover: #4f46e5;
            --green: #10b981;
            --orange: #f59e0b;
            --purple: #a855f7;
            --red: #ef4444;
            --radius-lg: 16px;
            --radius-md: 10px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        body {
            background-color: var(--bg-page);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 24px 32px;
        }

        .container {
            max-width: 1300px;
            margin: 0 auto;
        }

        /* Header */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border);
            margin-bottom: 28px;
        }

        .logo-box {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .logo-icon {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, #6366f1, #a855f7);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 20px;
            box-shadow: 0 8px 20px rgba(99, 102, 241, 0.35);
        }

        .logo-text h1 {
            font-size: 22px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .logo-text p {
            font-size: 13px;
            color: var(--text-muted);
        }

        .btn-add {
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: #fff;
            padding: 10px 22px;
            border-radius: 10px;
            border: none;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-add:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.45);
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 18px;
            margin-bottom: 28px;
        }

        .stat-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .stat-card .info p {
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 4px;
        }

        .stat-card .info h2 {
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -1px;
        }

        .stat-badge {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        /* Filter & Search Bar */
        .filter-bar {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 20px;
            display: flex;
            flex-wrap: wrap;
            gap: 14px;
            align-items: center;
            margin-bottom: 24px;
        }

        .search-input {
            flex: 1;
            min-width: 250px;
            background: #0f172a;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 10px 16px;
            color: #fff;
            font-size: 14px;
            outline: none;
        }

        .search-input:focus {
            border-color: var(--accent);
        }

        .filter-select {
            background: #0f172a;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 10px 14px;
            color: #fff;
            font-size: 14px;
            outline: none;
            cursor: pointer;
        }

        /* Table */
        .table-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            background: #172033;
            padding: 16px 20px;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            font-weight: 600;
            border-bottom: 1px solid var(--border);
        }

        td {
            padding: 16px 20px;
            border-bottom: 1px solid #233149;
            font-size: 14px;
            vertical-align: middle;
        }

        tr:hover td {
            background-color: var(--bg-card-hover);
        }

        .user-col {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 14px;
            color: #fff;
        }

        .user-info .name {
            font-weight: 600;
            color: #fff;
        }

        .user-info .emp-id {
            font-size: 12px;
            color: var(--text-muted);
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-active { background: rgba(16, 185, 129, 0.15); color: #34d399; }
        .badge-leave { background: rgba(245, 158, 11, 0.15); color: #fbbf24; }
        .badge-probation { background: rgba(168, 85, 247, 0.15); color: #c084fc; }

        .btn-delete {
            background: transparent;
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #f87171;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.2s;
        }

        .btn-delete:hover {
            background: #ef4444;
            color: #fff;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(4px);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-content {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            width: 100%;
            max-width: 540px;
            padding: 28px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .modal-header h3 {
            font-size: 18px;
            font-weight: 700;
        }

        .close-btn {
            background: none;
            border: none;
            color: var(--text-muted);
            font-size: 22px;
            cursor: pointer;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-group.full {
            grid-column: span 2;
        }

        .form-group label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
        }

        .form-group input, .form-group select, .form-group textarea {
            background: #0f172a;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 9px 12px;
            color: #fff;
            font-size: 13px;
            outline: none;
        }

        .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
            border-color: var(--accent);
        }

        .modal-footer {
            margin-top: 22px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .btn-cancel {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
        }

        /* Success Alert */
        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            border: 1px solid rgba(16, 185, 129, 0.4);
            color: #34d399;
            padding: 12px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <header>
            <div class="logo-box">
                <div class="logo-icon">N</div>
                <div class="logo-text">
                    <h1>NEXUS People</h1>
                    <p>Enterprise Employee Hub & Directory</p>
                </div>
            </div>
            <button class="btn-add" onclick="openModal()">+ Add Employee</button>
        </header>

        @if(session('success'))
            <div class="alert-success">{{ session('success') }}</div>
        @endif

        <!-- Stats Overview -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="info">
                    <p>Total Headcount</p>
                    <h2>{{ $stats['total'] }}</h2>
                </div>
                <div class="stat-badge" style="background: rgba(99, 102, 241, 0.15); color: #818cf8;">👥</div>
            </div>
            <div class="stat-card">
                <div class="info">
                    <p>Active Staff</p>
                    <h2>{{ $stats['active'] }}</h2>
                </div>
                <div class="stat-badge" style="background: rgba(16, 185, 129, 0.15); color: #34d399;">⚡</div>
            </div>
            <div class="stat-card">
                <div class="info">
                    <p>On Leave</p>
                    <h2>{{ $stats['on_leave'] }}</h2>
                </div>
                <div class="stat-badge" style="background: rgba(245, 158, 11, 0.15); color: #fbbf24;">🏖️</div>
            </div>
            <div class="stat-card">
                <div class="info">
                    <p>On Probation</p>
                    <h2>{{ $stats['probation'] }}</h2>
                </div>
                <div class="stat-badge" style="background: rgba(168, 85, 247, 0.15); color: #c084fc;">🎯</div>
            </div>
        </div>

        <!-- Filter Bar -->
        <form method="GET" action="/" class="filter-bar">
            <input type="text" name="search" class="search-input" placeholder="Search by name, ID or email..." value="{{ request('search') }}">
            <select name="department" class="filter-select" onchange="this.form.submit()">
                <option value="">All Departments</option>
                @foreach($departments as $dept)
                    <option value="{{ $dept }}" {{ request('department') == $dept ? 'selected' : '' }}>{{ $dept }}</option>
                @endforeach
            </select>
            <select name="status" class="filter-select" onchange="this.form.submit()">
                <option value="">All Statuses</option>
                <option value="Active" {{ request('status') == 'Active' ? 'selected' : '' }}>Active</option>
                <option value="On Leave" {{ request('status') == 'On Leave' ? 'selected' : '' }}>On Leave</option>
                <option value="Probation" {{ request('status') == 'Probation' ? 'selected' : '' }}>Probation</option>
            </select>
            <button type="submit" class="btn-add" style="padding: 9px 16px;">Search</button>
        </form>

        <!-- Employee Table -->
        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>Employee</th>
                        <th>Department</th>
                        <th>Designation</th>
                        <th>Status</th>
                        <th>Joined</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($employees as $emp)
                        <tr>
                            <td>
                                <div class="user-col">
                                    <div class="avatar" style="background: linear-gradient(135deg, #6366f1, #3b82f6)">
                                        {{ strtoupper(substr($emp->full_name, 0, 1)) }}
                                    </div>
                                    <div class="user-info">
                                        <div class="name">{{ $emp->full_name }}</div>
                                        <div class="emp-id">{{ $emp->employee_id }} • {{ $emp->email }}</div>
                                    </div>
                                </div>
                            </td>
                            <td>{{ $emp->department }}</td>
                            <td>{{ $emp->designation }}</td>
                            <td>
                                @if($emp->employment_status == 'Active')
                                    <span class="badge badge-active">Active</span>
                                @elseif($emp->employment_status == 'On Leave')
                                    <span class="badge badge-leave">On Leave</span>
                                @else
                                    <span class="badge badge-probation">Probation</span>
                                @endif
                            </td>
                            <td style="color: var(--text-muted)">{{ date('M d, Y', strtotime($emp->joining_date)) }}</td>
                            <td>
                                <form method="POST" action="/employees/{{ $emp->id }}" onsubmit="return confirm('Are you sure you want to remove {{ $emp->full_name }}?');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn-delete">Remove</button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 40px;">
                                No employees found. Click "+ Add Employee" to add one!
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Add Employee Modal -->
    <div id="modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Add New Employee</h3>
                <button class="close-btn" onclick="closeModal()">&times;</button>
            </div>
            <form method="POST" action="/employees">
                @csrf
                <div class="form-grid">
                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" name="employee_id" placeholder="e.g. NEX-1009" required>
                    </div>
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="full_name" placeholder="Full name" required>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="email@company.com" required>
                    </div>
                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="text" name="phone" placeholder="+1 (555) 000-0000" required>
                    </div>
                    <div class="form-group">
                        <label>Department</label>
                        <select name="department" required>
                            <option value="Engineering">Engineering</option>
                            <option value="Design">Design</option>
                            <option value="Product">Product</option>
                            <option value="Marketing">Marketing</option>
                            <option value="Finance">Finance</option>
                            <option value="HR">HR</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Designation</label>
                        <input type="text" name="designation" placeholder="e.g. Senior Architect" required>
                    </div>
                    <div class="form-group">
                        <label>Joining Date</label>
                        <input type="date" name="joining_date" value="{{ date('Y-m-d') }}" required>
                    </div>
                    <div class="form-group">
                        <label>Employment Status</label>
                        <select name="employment_status">
                            <option value="Active">Active</option>
                            <option value="On Leave">On Leave</option>
                            <option value="Probation">Probation</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeModal()">Cancel</button>
                    <button type="submit" class="btn-add">Save Employee</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() {
            document.getElementById('modal').style.display = 'flex';
        }
        function closeModal() {
            document.getElementById('modal').style.display = 'none';
        }
        window.onclick = function(event) {
            const modal = document.getElementById('modal');
            if (event.target === modal) {
                closeModal();
            }
        };
    </script>
</body>
</html>
