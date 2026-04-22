# PrakritiOPD
## Course Project Report

**Student Name:** ______________________  
**Roll Number:** ______________________  
**Course Name:** ______________________  
**Department:** ______________________  
**Institute:** ______________________  
**Submission Date:** ______________________  

---

## Index

1. Introduction  
2. E-R Diagram of the Project  
3. Literature Survey  
4. Sample Screenshots  
5. Conclusion  
6. Future Scope  
7. References  

---

## 1. Introduction

The **PrakritiOPD** system is a complete clinic management solution designed for Ayurvedic and Panchakarma treatment centers. The purpose of this project is to digitize and organize day-to-day clinical operations such as patient registration, appointment scheduling, doctor consultation workflow, therapist session management, billing, payment tracking, inventory monitoring, and reporting.

Traditional clinic operations are often handled manually through paper files, spreadsheets, and disconnected registers. This creates problems such as appointment confusion, inconsistent billing, weak patient history tracking, poor inventory control, and difficulty in generating management reports. To solve these issues, this project provides a centralized, database-driven web application where different users can securely perform their role-based tasks through a common system.

The project has been developed using:

- **Frontend:** React.js with Tailwind CSS
- **Backend:** Node.js with Express.js
- **Database:** MySQL
- **Authentication:** JWT-based login with role-based access control

The system supports the following user roles:

- **Admin**
- **Doctor**
- **Therapist**
- **Receptionist**
- **Patient**

Each role has specific permissions and workflows. For example, receptionists manage patient registration and appointments, doctors prepare treatment plans, therapists complete therapy sessions and log usage of oils/medicines, and patients can view their own treatment and billing information.

This project is not limited to basic CRUD operations. It uses **advanced RDBMS concepts** such as:

- primary keys and foreign keys
- constraints
- indexes
- views
- stored procedures
- stored functions
- triggers
- audit logging

These features help in enforcing business logic at the database level, maintaining data integrity, automating operational tasks, and ensuring reliable data consistency.

The final outcome is a clinic-ready application that demonstrates both software engineering and database management concepts in a practical healthcare setting.

---

## 2. E-R Diagram of the Project

The major entities in the system are:

- `Roles`
- `Users`
- `Patients`
- `Doctors`
- `Therapists`
- `Therapies`
- `Packages`
- `Package_Therapies`
- `Treatment_Plans`
- `Appointments`
- `Therapy_Sessions`
- `Suppliers`
- `Inventory_Items`
- `Session_Inventory_Usage`
- `Bills`
- `Payments`
- `Feedback`
- `Audit_Log`

### Entity Relationship Description

1. One **Role** can be assigned to many **Users**.
2. One **User** may represent an Admin, Doctor, Therapist, Receptionist, or Patient.
3. One **Patient** can have many **Treatment Plans**.
4. One **Doctor** can create many **Treatment Plans**.
5. One **Treatment Plan** may belong to one **Package**.
6. One **Package** can contain many **Therapies** through `Package_Therapies`.
7. One **Patient** can have many **Appointments**.
8. One **Appointment** may be linked to one **Therapy** and one **Therapist**.
9. One **Appointment** can produce one **Therapy Session**.
10. One **Therapy Session** can consume many **Inventory Items** through `Session_Inventory_Usage`.
11. One **Patient** can have many **Bills**.
12. One **Bill** can have many **Payments**.
13. One **Patient** can submit **Feedback** for therapy sessions.
14. All important system activities are captured in **Audit_Log**.

### Textual E-R Diagram

```text
ROLES 1 ----------- M USERS
USERS 1 ----------- 1 DOCTORS
USERS 1 ----------- 1 THERAPISTS
USERS 1 ----------- 1 PATIENTS

PATIENTS 1 -------- M TREATMENT_PLANS
DOCTORS 1 --------- M TREATMENT_PLANS
PACKAGES 1 -------- M TREATMENT_PLANS

PACKAGES 1 -------- M PACKAGE_THERAPIES M -------- 1 THERAPIES

PATIENTS 1 -------- M APPOINTMENTS
TREATMENT_PLANS 1 - M APPOINTMENTS
THERAPIES 1 ------- M APPOINTMENTS
THERAPISTS 1 ------ M APPOINTMENTS

APPOINTMENTS 1 ---- 1 THERAPY_SESSIONS
THERAPY_SESSIONS 1 - M SESSION_INVENTORY_USAGE M --- 1 INVENTORY_ITEMS

SUPPLIERS 1 ------- M INVENTORY_ITEMS

PATIENTS 1 -------- M BILLS
APPOINTMENTS 1 ---- M BILLS
BILLS 1 ----------- M PAYMENTS

PATIENTS 1 -------- M FEEDBACK
THERAPY_SESSIONS 1 - M FEEDBACK
THERAPISTS 1 ------ M FEEDBACK

USERS 1 ----------- M AUDIT_LOG
```

### Optional Diagram Space

Paste your hand-drawn or tool-generated E-R diagram here in the final report document/PDF.

**[Insert E-R Diagram Image Here]**

---

## 3. Literature Survey

This project uses several important **RDBMS and PL/SQL/MySQL procedural concepts**. These concepts are discussed below.

### 3.1 Relational Database Management System

A Relational Database Management System stores data in the form of tables with rows and columns. Relationships between tables are maintained using keys. In this project, MySQL is used as the RDBMS because it is reliable, scalable, and widely adopted in industry applications.

Important relational concepts used:

- entity and relationship modeling
- normalization
- primary key and foreign key relationships
- constraints and validation
- transaction-safe updates

### 3.2 Primary Keys and Foreign Keys

Each main table contains a **primary key** to uniquely identify each record. Relationships across tables are enforced through **foreign keys**.

Examples:

- `users.role_id` references `roles.id`
- `treatment_plans.patient_id` references `patients.id`
- `appointments.therapy_id` references `therapies.id`
- `payments.bill_id` references `bills.id`

These relationships ensure referential integrity and prevent invalid data entry.

### 3.3 Constraints

Constraints are used to enforce data correctness at the database level.

Examples used in this project:

- `UNIQUE` constraints on email and patient code
- `CHECK` constraints on quantity, cost, rating, and duration values
- `ENUM` values for controlled states such as appointment status and bill status
- `NOT NULL` constraints on mandatory fields

Constraints reduce inconsistent or invalid data and improve reliability of the application.

### 3.4 Stored Procedures

Stored procedures are predefined SQL programs stored inside the database and executed when needed. They are used to centralize business logic and improve reusability.

Stored procedures implemented in this project include:

- `sp_register_patient`
- `sp_book_appointment`
- `sp_complete_therapy_session`
- `sp_log_session_inventory_usage`
- `sp_generate_bill_for_appointment`
- `sp_record_bill_payment`
- `sp_patient_treatment_history`
- `sp_monthly_revenue_report`

Benefits of using stored procedures:

- business rules remain inside the database
- application code becomes cleaner
- reduces duplicate SQL logic
- improves consistency across operations

### 3.5 Stored Functions

Stored functions are reusable database routines that return a value.

Functions used in this project:

- `fn_patient_age`  
  Calculates patient age from date of birth.

- `fn_bill_balance`  
  Returns the pending amount of a bill.

These functions simplify common calculations and improve query readability.

### 3.6 Views

Views are virtual tables based on SQL queries. They present processed or summarized data without duplicating it physically.

Views used in this project:

- `vw_patient_master_summary`
- `vw_appointment_calendar`
- `vw_inventory_alerts`
- `vw_billing_summary`
- `vw_doctor_performance`

Purpose of using views:

- simplify complex reporting queries
- provide cleaner data access to the application
- improve modularity
- support dashboard and analytics pages

### 3.7 Triggers

Triggers automatically execute when specific database events occur such as insert, update, or delete. They are very useful for automation and integrity enforcement.

Triggers used in this project include:

- inventory deduction after session usage insert
- bill calculation before bill insert
- payment-based bill status update after payment insert
- appointment state validation before update
- audit log creation for patient, appointment, bill, payment, and session operations

Why triggers are important in this project:

- reduce manual errors
- keep inventory updated automatically
- update bill balance and status automatically
- prevent invalid status transitions
- record system activity without depending only on frontend logic

### 3.8 Indexes

Indexes are created to improve search and retrieval performance.

Indexes are used on:

- patient search fields
- appointment date and status
- billing status/date
- audit log fields
- inventory expiry and stock status

Indexes improve performance for dashboards, filters, and reports.

### 3.9 Audit Logging

Audit logging is a major feature for real-world systems. It helps track who performed what action and when. In healthcare and clinic systems, this is important for accountability and traceability.

The project logs actions such as:

- patient creation
- appointment creation and status change
- bill generation
- payment recording
- session updates

This supports secure and transparent system usage.

### 3.10 Role-Based Access Control

RBAC is used to limit access based on the user role. The backend verifies the role using JWT and middleware.

Examples:

- only admin/receptionist can register patients
- only doctor/admin can manage treatment plans
- only therapist/admin can record therapy sessions
- patient can only view their own portal information

This improves security and ensures correct workflow separation.

### 3.11 Conclusion of Literature Survey

The project demonstrates that modern database applications must go beyond basic table storage. Concepts such as procedures, views, triggers, constraints, and RBAC are essential for building reliable and production-oriented systems. These database mechanisms improve integrity, automation, performance, and security, making the solution suitable for real clinic workflow management.

---

## 4. Sample Screenshots

Add your screenshots in this section while preparing the final Word/PDF report.

### 4.1 Landing Page

**[Insert Screenshot Here]**

### 4.2 Login Page

**[Insert Screenshot Here]**

### 4.3 Admin Dashboard

**[Insert Screenshot Here]**

### 4.4 Doctor Dashboard

**[Insert Screenshot Here]**

### 4.5 Receptionist Dashboard

**[Insert Screenshot Here]**

### 4.6 Therapist Dashboard

**[Insert Screenshot Here]**

### 4.7 Patient Dashboard

**[Insert Screenshot Here]**

### 4.8 Appointment Management Screen

**[Insert Screenshot Here]**

### 4.9 Treatment Plan Management

**[Insert Screenshot Here]**

### 4.10 Billing and Payment Screen

**[Insert Screenshot Here]**

### 4.11 Inventory Management Screen

**[Insert Screenshot Here]**

### 4.12 Database Objects / SQL Execution

**[Insert Screenshot Here]**

---

## 5. Conclusion

The **PrakritiOPD** system successfully addresses the operational requirements of an Ayurvedic clinic by integrating patient management, appointment scheduling, treatment planning, therapist workflows, billing, inventory monitoring, and reporting into one centralized application.

This project demonstrates the practical importance of database concepts in a real-world application. Instead of depending only on frontend or backend application logic, major operations are reinforced through MySQL-level constraints, procedures, views, functions, and triggers. As a result, the system maintains data accuracy, reduces duplication, automates repetitive processes, and preserves consistency across all modules.

The use of role-based access control ensures that each user interacts only with the features relevant to their responsibilities. The web interface allows clinic staff and patients to access operational data in a structured and responsive way, while the database layer ensures that every action is validated and traceable.

Thus, this project serves as a strong example of how RDBMS concepts can be combined with web technologies to build a robust, practical, and scalable healthcare management application.

---

## 6. Future Scope

Although the current system is complete and functional, the following enhancements can be implemented in future versions:

- online payment gateway integration
- WhatsApp/SMS/email reminders for appointments and bills
- doctor prescription PDF generation
- Cloudinary or AWS S3 document uploads
- multi-branch clinic support
- staff attendance and payroll module
- pharmacy sales integration
- advanced analytics dashboards with charts
- mobile application for patients and staff
- backup scheduling and disaster recovery tools
- AI-based therapy recommendation support
- insurance claim workflow integration

These improvements can make the system even more suitable for deployment in large clinics and wellness centers.

---

## 7. References

1. MySQL 8.0 Documentation  
   [https://dev.mysql.com/doc/](https://dev.mysql.com/doc/)

2. Node.js Documentation  
   [https://nodejs.org/en/docs](https://nodejs.org/en/docs)

3. Express.js Documentation  
   [https://expressjs.com/](https://expressjs.com/)

4. React Documentation  
   [https://react.dev/](https://react.dev/)

5. JWT Introduction and Usage  
   [https://jwt.io/](https://jwt.io/)

6. Database System Concepts, Abraham Silberschatz, Henry F. Korth, S. Sudarshan

7. Elmasri and Navathe, Fundamentals of Database Systems

---

## Final Note

You can now:

- fill in your name, roll number, and course details
- add screenshots in the blank sections
- convert this Markdown content into Word or PDF format for submission
