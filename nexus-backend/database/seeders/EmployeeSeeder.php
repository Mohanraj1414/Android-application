<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Employee;

class EmployeeSeeder extends Seeder
{
    public function run(): void
    {
        $employees = [
            [
                'employee_id' => 'NEX-1001',
                'full_name' => 'Sarah Jenkins',
                'email' => 'sarah.jenkins@nexuscorp.com',
                'phone' => '+1 (415) 890-2341',
                'department' => 'Engineering',
                'designation' => 'VP of Engineering',
                'joining_date' => '2022-03-15',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'San Francisco, CA',
                'avatar_color' => 4283336421,
                'notes' => 'Leads 45+ distributed engineers. Architect of NEXUS cloud infrastructure.',
            ],
            [
                'employee_id' => 'NEX-1002',
                'full_name' => 'Marcus Vance',
                'email' => 'marcus.vance@nexuscorp.com',
                'phone' => '+1 (415) 555-0142',
                'department' => 'Design',
                'designation' => 'Principal Product Designer',
                'joining_date' => '2022-06-01',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'San Francisco, CA',
                'avatar_color' => 4280391411,
                'notes' => 'Owns the design system and mobile UX architecture.',
            ],
            [
                'employee_id' => 'NEX-1003',
                'full_name' => 'Amina Diallo',
                'email' => 'amina.diallo@nexuscorp.com',
                'phone' => '+1 (212) 555-0189',
                'department' => 'Product',
                'designation' => 'Director of Product',
                'joining_date' => '2021-11-10',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'New York, NY',
                'avatar_color' => 4282348500,
                'notes' => 'Responsible for core SaaS monetization and user growth roadmap.',
            ],
            [
                'employee_id' => 'NEX-1004',
                'full_name' => 'Carlos Rodriguez',
                'email' => 'carlos.rodriguez@nexuscorp.com',
                'phone' => '+1 (512) 555-0177',
                'department' => 'Engineering',
                'designation' => 'Senior DevOps Engineer',
                'joining_date' => '2023-01-20',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'Austin, TX',
                'avatar_color' => 4279346850,
                'notes' => 'Kubernetes infrastructure lead and CI/CD automation specialist.',
            ],
            [
                'employee_id' => 'NEX-1005',
                'full_name' => 'Elena Rostova',
                'email' => 'elena.rostova@nexuscorp.com',
                'phone' => '+1 (206) 555-0133',
                'department' => 'Marketing',
                'designation' => 'Head of Brand Strategy',
                'joining_date' => '2023-04-12',
                'employment_type' => 'Full-time',
                'employment_status' => 'On Leave',
                'location' => 'Seattle, WA',
                'avatar_color' => 4293998894,
                'notes' => 'On maternity leave until August. Contact interim lead for approvals.',
            ],
            [
                'employee_id' => 'NEX-1006',
                'full_name' => 'Liam Gallagher',
                'email' => 'liam.gallagher@nexuscorp.com',
                'phone' => '+1 (312) 555-0195',
                'department' => 'Finance',
                'designation' => 'Financial Controller',
                'joining_date' => '2022-09-01',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'Chicago, IL',
                'avatar_color' => 4280854400,
                'notes' => 'Manages quarterly investor audits and enterprise vendor budgets.',
            ],
            [
                'employee_id' => 'NEX-1007',
                'full_name' => 'Priya Patel',
                'email' => 'priya.patel@nexuscorp.com',
                'phone' => '+1 (408) 555-0164',
                'department' => 'Engineering',
                'designation' => 'Staff Machine Learning Engineer',
                'joining_date' => '2023-07-15',
                'employment_type' => 'Full-time',
                'employment_status' => 'Active',
                'location' => 'San Jose, CA',
                'avatar_color' => 4287514330,
                'notes' => 'Leading the GenAI integration and intelligent predictive algorithms.',
            ],
            [
                'employee_id' => 'NEX-1008',
                'full_name' => 'Thomas Wright',
                'email' => 'thomas.wright@nexuscorp.com',
                'phone' => '+1 (617) 555-0128',
                'department' => 'HR',
                'designation' => 'Talent Acquisition Manager',
                'joining_date' => '2024-02-01',
                'employment_type' => 'Full-time',
                'employment_status' => 'Probation',
                'location' => 'Boston, MA',
                'avatar_color' => 4290807600,
                'notes' => '90-day onboarding period. Focused on technical hiring in APAC.',
            ],
        ];

        foreach ($employees as $data) {
            Employee::updateOrCreate(['employee_id' => $data['employee_id']], $data);
        }
    }
}
