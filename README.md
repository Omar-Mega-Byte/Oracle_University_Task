# Oracle_University_Task
An Oracle SQL project managing academic operations with triggers, procedures, and functions for validation, grade calculation, warnings, and audit logging.
# Exam and Student Management System

## Overview
This project implements a robust Exam and Student Management System using Oracle SQL and PL/SQL. It encompasses various features to manage academic courses, exams, student registrations, and academic performance. The system ensures data integrity, enforces business rules, and provides tools for monitoring and analysis.

## Features

### 1. Prerequisite Validation
- Ensures that students meet course prerequisites before registration.
- Automatically prevents registrations that violate prerequisite conditions.

### 2. Grade Calculation
- Dynamically calculates letter grades based on numeric scores.
- Updates the database with calculated grades and academic status (e.g., passed or failed).

### 3. Student Warnings
- Issues warnings to students who fail two or more courses.
- Logs warning details for future reference.

### 4. Audit Logging
- Tracks changes to the `Register` table for both insertions and deletions.
- Records the timestamp, operation type, and data changes.

### 5. Course Performance Report
- Generates a report showing the number of students who passed or failed a specific course.
- Provides detailed performance insights per course.

### 6. Exam Schedule Management
- Displays the exam schedule for specific courses, including exam dates and types.
- Offers quick access to upcoming exams.

### 7. Batch Grade Updates
- Updates grades for multiple exams within a single transaction.
- Implements rollback functionality to maintain data consistency in case of errors.

### 8. Student Suspension
- Suspends students who receive three or more warnings.
- Logs suspension details in an audit trail.

## Implementation Details

### Roles and Permissions
- **Role Creation:** Custom roles and privileges are defined to ensure proper access control.
- **User Management:** Assigns roles and quotas for managing database resources.

### Database Objects
- **Triggers:** Enforce business rules such as audit logging and prerequisite validation.
- **Stored Procedures:** Automate processes like issuing warnings and suspending students.
- **Functions:** Calculate grades and return results dynamically.
- **Cursors:** Generate reports and manage transactions efficiently.

### Tables and Data Management
- **Exams Table:** Stores exam details such as type, date, and associated courses.
- **ExamResults Table:** Records student performance for exams.
- **Warnings Table:** Logs warnings issued to students.
- **AuditTrail Table:** Tracks all significant changes for accountability.

### Transactions and Rollbacks
- Ensures atomicity and consistency by rolling back transactions in case of errors.
- Handles complex updates and inserts seamlessly.

## Usage

### Prerequisites
- Oracle Database with appropriate permissions.
- SQL*Plus or another client for executing scripts.

### Setup
1. Run the provided SQL scripts to create necessary roles, users, tables, and sequences.
2. Grant appropriate privileges and quotas.
3. Insert initial test data for courses, students, exams, and registrations.

### Execution
- Use the provided SQL and PL/SQL scripts to perform operations like grade calculation, issuing warnings, generating reports, and more.
- Customize scripts to adapt to specific academic management scenarios.

### Maintenance
- Regularly review audit trails and warnings.
- Monitor database performance and optimize queries as needed.

## Future Enhancements
- Implement a web-based front end for user interaction.
- Add advanced analytics for academic performance.
- Introduce automated notifications for warnings and schedule changes.

## License
This project is released under the [MIT License](LICENSE).

### Team Members:
- Omar Ahmed
- Refaat Ismail
- Sara Ashraf
- Sara Ahmed 
- Ali Gomaa
- Ahmed Maghawry
- Hussien Ahmed
