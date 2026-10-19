<?php

use Illuminate\Support\Facades\Route;
use App\Models\Employee;
use Illuminate\Http\Request;

Route::get('/', function (Request $request) {
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

    $employees = $query->latest()->get();

    $stats = [
        'total' => Employee::count(),
        'active' => Employee::where('employment_status', 'Active')->count(),
        'on_leave' => Employee::where('employment_status', 'On Leave')->count(),
        'probation' => Employee::where('employment_status', 'Probation')->count(),
    ];

    $departments = Employee::select('department')->distinct()->pluck('department');

    return view('dashboard', compact('employees', 'stats', 'departments'));
});

Route::post('/employees', function (Request $request) {
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
        'notes' => 'nullable|string',
    ]);

    Employee::create($validated);
    return redirect()->back()->with('success', 'Employee created successfully!');
});

Route::delete('/employees/{employee}', function (Employee $employee) {
    $employee->delete();
    return redirect()->back()->with('success', 'Employee deleted successfully!');
});
