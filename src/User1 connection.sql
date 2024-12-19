CREATE TABLE Professors (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    department VARCHAR2(100)
);

CREATE TABLE Students (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    academic_status VARCHAR2(50) CHECK (academic_status IN ('active', 'suspended')),
    total_credits NUMBER
);

CREATE TABLE Courses (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    professor_id NUMBER,
    credit_hours NUMBER,
    prerequisite_course_id NUMBER,
    CONSTRAINT fk_professor FOREIGN KEY (professor_id) REFERENCES Professors(id),
    CONSTRAINT fk_preCourseId FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(id) --بيعوز فورين كيي الكورس اي دي بتاع المتطلب السابق
);

CREATE TABLE Register (
    id NUMBER PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES Students(id),
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES Courses(id)
);
-------------------------------------------------------> Feature 10,11
UPDATE User1.Students
SET academic_status = 'suspended'
WHERE id = 4;

--COMMIT; -- Uncomment this after observing the blocking

select * from User1.students;
-------------------------------------------------------------- Feature 12
BEGIN
    LOCK TABLE Register IN EXCLUSIVE MODE;
    UPDATE Courses SET name = 'New Course' WHERE id = 1;
    COMMIT;
END;
select * from courses
--------------------------------------------------------------
--DROP TABLE Courses;
--DROP TABLE Professors;
--DROP TABLE Students
--DROP TABLE Register