<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('employees', function (Blueprint $table) {
            $table->id();
            $table->string('employee_id')->unique();
            $table->string('full_name');
            $table->string('email')->unique();
            $table->string('phone');
            $table->string('department');
            $table->string('designation');
            $table->date('joining_date');
            $table->string('employment_type')->default('Full-Time');
            $table->string('employment_status')->default('Active');
            $table->string('location')->default('HQ');
            $table->bigInteger('avatar_color')->default(4280391411);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('employees');
    }
};