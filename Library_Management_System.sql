-- Project 2: Library Management System
-- MySQL - books, authors, members, borrowing

CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

-- Tables

CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50),
    birth_year INT
);

CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(150) NOT NULL,
    publication_year INT,
    available_copies INT DEFAULT 1 CHECK (available_copies >= 0)
);

CREATE TABLE Book_Authors (   -- junction table for many-to-many
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE DEFAULT (CURRENT_DATE),
    phone VARCHAR(15)
);

CREATE TABLE Borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

-- Sample Data

INSERT INTO Authors (full_name, nationality, birth_year) VALUES
('Chimamanda Ngozi Adichie', 'Nigeria', 1977),
('J.K. Rowling', 'United Kingdom', 1965),
('Zakes Mda', 'South Africa', 1948),
('Trevor Noah', 'South Africa', 1984);

INSERT INTO Books (isbn, title, publication_year, available_copies) VALUES
('978-0307476463', 'Half of a Yellow Sun', 2006, 3),
('978-0545582933', 'Harry Potter and the Sorcerer''s Stone', 1997, 5),
('978-0374531263', 'Ways of Dying', 1995, 2),
('978-0399588174', 'Born a Crime', 2016, 4);

INSERT INTO Book_Authors (book_id, author_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

INSERT INTO Members (first_name, last_name, email, phone) VALUES
('Lungelo', 'Moyo', 'lungo.m@email.com', '082-123-4567'),
('Nomsa', 'Khumalo', 'nomsa.k@email.com', '083-987-6543'),
('Sibusiso', 'Radebe', 'sibu.r@email.com', NULL);

INSERT INTO Borrowings (member_id, book_id, due_date, return_date) VALUES
(1, 1, '2026-02-20', NULL),          -- currently borrowed
(2, 2, '2026-02-10', '2026-02-05'),   -- returned
(1, 4, '2026-03-01', NULL),
(3, 3, '2026-02-15', NULL);

--Queries

-- Books currently borrowed with member info
SELECT 
    b.title,
    m.first_name,
    m.last_name,
    br.borrow_date,
    br.due_date
FROM Books b
JOIN Borrowings br ON b.book_id = br.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL;

-- Overdue books (assuming current date is 2026-02-07)
SELECT 
    b.title,
    m.first_name || ' ' || m.last_name AS member,
    br.due_date
FROM Borrowings br
JOIN Books b ON br.book_id = b.book_id
JOIN Members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL 
  AND br.due_date < CURRENT_DATE;

-- Most popular books (by borrow count)
SELECT 
    b.title,
    COUNT(br.borrowing_id) AS borrow_count
FROM Books b
LEFT JOIN Borrowings br ON b.book_id = br.book_id
GROUP BY b.book_id
ORDER BY borrow_count DESC;

-- Update returned book
UPDATE Borrowings 
SET return_date = CURRENT_DATE 
WHERE borrowing_id = 2;

-- Decrease available copies when borrowed (you can make a trigger later)
UPDATE Books 
SET available_copies = available_copies - 1 
WHERE book_id = 1;
