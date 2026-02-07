-- Project 1: Student Management System
-- PMySQL script - creates DB, tables, inserts data, and example queries

--Create Database
CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

--Create Tables

CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    enrollment_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits > 0)
);

CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade CHAR(1),  -- A,B,C,D,F or NULL if ongoing
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY (student_id, course_id)  -- prevent duplicate enrollments
);

--Insert Sample Data

INSERT INTO Students (first_name, last_name, email, date_of_birth) VALUES
('Amahle', 'Nkosi', 'amahle.nkosi@email.com', '2003-05-12'),
('Thabo', 'Mthembu', 'thabo.m@email.com', '2002-11-03'),
('Zinhle', 'Dlamini', 'zinhle.d@email.com', '2004-02-28'),
('Sipho', 'Ndlovu', 'sipho.n@email.com', '2001-09-15');

INSERT INTO Courses (course_code, course_name, credits) VALUES
('CS101', 'Introduction to Programming', 4),
('MATH201', 'Calculus II', 5),
('ENG150', 'Academic English', 3),
('HIST110', 'South African History', 3);

INSERT INTO Enrollments (student_id, course_id, grade) VALUES
(1, 1, 'A'),
(1, 2, 'B'),
(2, 1, 'C'),
(2, 3, 'A'),
(3, 4, 'B'),
(4, 1, NULL),   -- still ongoing
(4, 2, 'D');

-- Queries

-- List all students with their number of courses
SELECT 
    s.first_name, 
    s.last_name, 
    COUNT(e.course_id) AS courses_enrolled
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id
ORDER BY courses_enrolled DESC;

-- Show average grade per course (A=4, B=3, C=2, D=1, F=0)
SELECT 
    c.course_name,
    AVG(CASE 
        WHEN e.grade = 'A' THEN 4
        WHEN e.grade = 'B' THEN 3
        WHEN e.grade = 'C' THEN 2
        WHEN e.grade = 'D' THEN 1
        WHEN e.grade = 'F' THEN 0
        ELSE NULL 
    END) AS avg_gpa
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
HAVING avg_gpa IS NOT NULL;

-- Students without grades (ongoing courses)
SELECT s.first_name, s.last_name, c.course_name
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE e.grade IS NULL;

-- Update a grade
UPDATE Enrollments 
SET grade = 'B' 
WHERE student_id = 4 AND course_id = 1;

-- Delete a student (cascades to enrollments)
-- DELETE FROM Students WHERE student_id = 4;
