<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    use HasFactory;

    protected $fillable = [
        'employee_id',
        'full_name',
        'email',
        'phone',
        'department',
        'designation',
        'joining_date',
        'employment_type',
        'employment_status',
        'location',
        'avatar_color',
        'notes',
    ];
}
