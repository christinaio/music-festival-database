# Music Festival Database

A relational database project designed to model and manage the operations of a multi-day music festival.

The project covers the database development process from conceptual and relational modeling to SQL implementation, data integrity constraints, and analytical queries.

## Project Overview

The database models key aspects of a music festival, including:

- Festivals, locations, stages, and events
- Artists, bands, genres, and subgenres
- Performances and performance schedules
- Visitors and ticketing
- Ticket pricing and payment methods
- Ticket resale requests
- Staff management
- Technical equipment
- Performance reviews and evaluation criteria

## Database Design

The database was designed using:

- **Entity-Relationship (ER) modeling**
- **Relational modeling**

Both diagrams are available in the `diagrams/` directory:

- `er.pdf` — Entity-Relationship diagram
- `relational.pdf` — Relational schema

## Database Implementation

The SQL implementation includes:

- Table creation
- Primary and foreign keys
- Referential integrity constraints
- Data validation rules
- Data loading
- Triggers for enforcing business rules

Database-level constraints are implemented to handle rules related to festival scheduling, performances, equipment, staff, ticketing, and other operational requirements.

## SQL Queries

The project includes **15 analytical SQL queries** addressing different festival management and data analysis questions.

The queries demonstrate the use of:

- Multi-table `JOIN` operations
- `LEFT JOIN`
- `GROUP BY` and `HAVING`
- Aggregate functions
- Nested subqueries
- Common Table Expressions (CTEs)
- `CASE` expressions
- `UNION`
- Date calculations
- Filtering and sorting

The analyses cover areas such as festival revenue, artist participation, performance ratings, visitor activity, genre popularity, staffing requirements, and artist participation across different locations.

## Repository Structure

    music-festival-database/
    │
    ├── diagrams/
    │   ├── er.pdf
    │   └── relational.pdf
    │
    ├── sql/
    │   ├── install.sql
    │   ├── load.sql
    │   ├── Q01.sql
    │   ├── Q02.sql
    │   ├── ...
    │   └── Q15.sql
    │
    ├── README.md
    └── LICENSE

## Technologies

- SQL
- MySQL
- Relational Database Design
- Entity-Relationship Modeling

## Key Skills Demonstrated

This project demonstrates practical experience in:

- Designing a relational database from real-world requirements
- Translating conceptual models into relational schemas
- Writing complex SQL queries across multiple related tables
- Implementing primary and foreign key relationships
- Enforcing data integrity through constraints and triggers
- Using SQL for analytical querying and data aggregation
