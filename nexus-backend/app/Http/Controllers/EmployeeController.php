<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use Illuminate\Http\Request;

class EmployeeController extends Controller
{
    // 1. GET /api/employees (supports ?search=&department=&status=)
    public function index(Request $request)
    {
        $query = Employee::query();

        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('employee_id', 'like', "%{$search}%");
            });
        }

        if ($request->filled('department')) {
            $query->where('department', $request->query('department'));
        }

        if ($request->filled('status')) {
            $query->where('employment_status', $request->query('status'));
        }

        return response()->json($query->latest()->get());
    }

    // 2. POST /api/employees (Create new employee)
    public function store(Request $request)
    {
        $validated = $request->validate([
            'employee_id' => 'required|string|unique:employees,employee_id',
            'full_name' => 'required|string|max:255',
            'email' => 'required|email|unique:employees,email',
            'phone' => 'required|string',
            'department' => 'required|string',
            'designation' => 'required|string',
            'joining_date' => 'required|date',
            'employment_type' => 'nullable|string',
            'employment_status' => 'nullable|string',
            'location' => 'nullable|string',
            'avatar_color' => 'nullable|integer',
            'notes' => 'nullable|string',
        ]);

        $employee = Employee::create($validated);
        return response()->json($employee, 201);
    }

    // 3. GET /api/employees/{id} (Single Employee)
    public function show(Employee $employee)
    {
        return response()->json($employee);
    }

    // 4. PUT /api/employees/{id} (Update Employee)
    public function update(Request $request, Employee $employee)
    {
        $validated = $request->validate([
            'full_name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:employees,email,' . $employee->id,
            'phone' => 'sometimes|string',
            'department' => 'sometimes|string',
            'designation' => 'sometimes|string',
            'employment_status' => 'sometimes|string',
            'location' => 'sometimes|string',
            'notes' => 'nullable|string',
        ]);

        $employee->update($validated);
        return response()->json($employee);
    }

    // 5. DELETE /api/employees/{id} (Remove Employee)
    public function destroy(Employee $employee)
    {
        $employee->delete();
        return response()->json(['message' => 'Employee deleted successfully']);
    }

    // 6. GET /api/dashboard/stats (Metrics for Dashboard)
    public function dashboardStats()
    {
        $total = Employee::count();
        $active = Employee::where('employment_status', 'Active')->count();
        $onLeave = Employee::where('employment_status', 'On Leave')->count();
        $probation = Employee::where('employment_status', 'Probation')->count();

        return response()->json([
            'total_employees' => $total,
            'active_employees' => $active,
            'on_leave_employees' => $onLeave,
            'probation_employees' => $probation,
        ]);
    }
}
