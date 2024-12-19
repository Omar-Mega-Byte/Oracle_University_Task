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
    CONSTRAINT fk_prerequisite FOREIGN KEY (prerequisite_course_id) REFERENCES Courses(id)
);

CREATE TABLE Register (
    id NUMBER PRIMARY KEY,
    student_id NUMBER,
    course_id NUMBER,
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES Students(id),
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES Courses(id)
);

CREATE TABLE Exams (
    id NUMBER PRIMARY KEY,
    course_id NUMBER,
    exam_date DATE,
    exam_type VARCHAR2(50),
    CONSTRAINT fk_exam_course FOREIGN KEY (course_id) REFERENCES Courses(id)
);

CREATE TABLE ExamResults (
    id NUMBER PRIMARY KEY,
    registration_id NUMBER,
    grade varchar(2),
    status VARCHAR2(50) CHECK (status IN ('passed', 'failed')),
    CONSTRAINT fk_registration FOREIGN KEY (registration_id) REFERENCES Register(id)
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
    CONSTRAINT fk_warning_student FOREIGN KEY (student_id) REFERENCES Students(id)
);
