---------------------------------------------
CREATE USER User1 IDENTIFIED BY 1234;
GRANT CREATE SESSION, CREATE TABLE TO User1;
ALTER USER User1 QUOTA 10M ON USERS;
---------------------------------------------> Half of it for testing use carfully
CREATE USER User2 IDENTIFIED BY 1234;
GRANT CREATE SESSION TO User2;
GRANT INSERT ON User1.Courses TO User2; --GRANT INSERT ON Courses TO User2;
GRANT INSERT ON User1.Students TO User2; --GRANT INSERT ON Students TO User2;
GRANT INSERT ON User1.Professors TO User2; --GRANT INSERT ON Professors TO User2;
GRANT INSERT ON User1.Register TO User2; --GRANT INSERT ON Register TO User2;
GRANT SELECT ON User1.Professors TO User2;
GRANT SELECT ON User1.Courses TO User2;
GRANT SELECT ON User1.Students TO User2;
GRANT SELECT ON User1.Register TO User2;
-------------------------------------------
CREATE TABLE Exams (
    id NUMBER PRIMARY KEY,
    course_id NUMBER,
    exam_date DATE,
    exam_type VARCHAR2(50),
    CONSTRAINT fk_exam_course FOREIGN KEY (course_id) REFERENCES User1.Courses(id)
);

CREATE TABLE ExamResults (
    id NUMBER PRIMARY KEY,
    registration_id NUMBER,
    grade VARCHAR2(2),
    status VARCHAR2(50) CHECK (status IN ('passed', 'failed')),
    CONSTRAINT fk_registration FOREIGN KEY (registration_id) REFERENCES User1.Register(id)
);
CREATE TABLE AuditTrail (
    id NUMBER PRIMARY KEY,
    table_name VARCHAR2(100),
    operation VARCHAR2(50),
    old_data VARCHAR2(4000),
    new_data VARCHAR2(4000),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Warnings (
    id NUMBER PRIMARY KEY,
    student_id NUMBER,
    warning_reason VARCHAR2(255),
    warning_date DATE,
    CONSTRAINT fk_warning_student FOREIGN KEY (student_id) REFERENCES User1.Students(id)
);

Drop table ExamsResults;