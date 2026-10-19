<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
use App\Http\Controllers\EmployeeController;

// Dashboard metrics
Route::get('dashboard/stats', [EmployeeController::class, 'dashboardStats']);

// Employee CRUD
Route::apiResource('employees', EmployeeController::class);
