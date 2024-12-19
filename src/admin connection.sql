alter session set "_ORACLE_SCRIPT"=true;
CREATE ROLE mRole;
GRANT CREATE USER TO mRole;            
GRANT DROP USER TO mRole; 
GRANT GRANT ANY PRIVILEGE TO mRole; 
GRANT CREATE SESSION TO mRole;
GRANT CREATE TABLE TO mRole;
GRANT REFERENCES ON User1.Courses TO ExamsManager;
GRANT REFERENCES ON User1.Register TO ExamsManager;
GRANT REFERENCES ON User1.Students TO ExamsManager;

GRANT INSERT ON User1.Courses TO ExamsManager; 
GRANT SELECT ON User1.Students TO ExamsManager; 
GRANT INSERT ON User1.Register TO ExamsManager; 

GRANT ALTER USER TO mRole;     
CREATE USER ExamsManager IDENTIFIED BY 1234;
GRANT mRole TO ExamsManager;
ALTER USER ExamsManager QUOTA 100M ON USERS;
-------------------------------------------
GRANT CREATE TABLE TO examsmanager;
GRANT CREATE TRIGGER TO examsmanager;
GRANT REFERENCES ON User1.Courses TO examsmanager;

INSERT INTO examsmanager.Exams (id, course_id, exam_date, exam_type) VALUES (1, 1, TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'Final');
INSERT INTO examsmanager.Exams (id, course_id, exam_date, exam_type) VALUES (2, 2, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'Midterm');
INSERT INTO examsmanager.Exams (id, course_id, exam_date, exam_type) VALUES (3, 3, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'Final');
INSERT INTO examsmanager.Exams (id, course_id, exam_date, exam_type) VALUES (4, 4, TO_DATE('2024-01-25', 'YYYY-MM-DD'), 'Quiz');
INSERT INTO examsmanager.Exams (id, course_id, exam_date, exam_type) VALUES (5, 5, TO_DATE('2024-01-30', 'YYYY-MM-DD'), 'Final');

Delete from examsmanager.ExamResults;
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) VALUES (1, 1, '99', 'passed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) VALUES (2, 2, '31', 'failed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) VALUES (3, 3, '80', 'passed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) VALUES (4, 4, '24', 'failed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) VALUES (5, 5, '70', 'passed');

-------------------------------------------> Feature 1 => Ensures the student has passed any prerequisite course before registering for a new course.
CREATE OR REPLACE TRIGGER exam_eligibility
BEFORE
INSERT
ON User1.Register
FOR EACH ROW
DECLARE
    prerequisite_course_id NUMBER;
    completed_count NUMBER;
BEGIN
    --we put here the value of prerequisite_course_id of the Coures that will be registered
    SELECT prerequisite_course_id
    INTO prerequisite_course_id
    FROM User1.Courses
    WHERE id = :NEW.course_id;
    
    IF prerequisite_course_id IS NOT NULL THEN
        -- WE here Check if the student has completed the prerequisite course
        SELECT COUNT(*)
        INTO completed_count
        FROM User1.Register r --> here we do a alias for the table as the letter r
        JOIN examsmanager.ExamResults er ON r.id = er.registration_id
        WHERE r.student_id = :NEW.student_id
          AND r.course_id = prerequisite_course_id
          AND er.status = 'passed';

        IF completed_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Prerequisite not met for the selected course.');
        END IF;
    END IF;
END;

select * from User1.courses;
select * from User1.register;
select * from examsmanager.examresults;

INSERT INTO User1.Register (id, student_id, course_id) VALUES (62, 1, 3);
INSERT INTO User1.Register (id, student_id, course_id) VALUES (66, 1, 4);

-------------------------------------------------------------------------------------->Feature 2 => Calculates a letter grade based on numeric score, updates the ExamResults table, and returns the grade.
select * from examsmanager.examresults;
CREATE OR REPLACE FUNCTION grade_calc (ex_id IN NUMBER)
RETURN VARCHAR2
IS
    stud_num_grade NUMBER;
    stud_char_grade VARCHAR2(2);
    stud_status VARCHAR2(50);
BEGIN
    -- Fetch the numeric grade for the given ExamResults ID
    SELECT grade INTO stud_num_grade
    FROM examsmanager.ExamResults
    WHERE id = ex_id;

    -- Determine the letter grade based on the predefined ranges
    IF stud_num_grade >= 90 THEN
        stud_char_grade := 'A';
        stud_status := 'passed';
    ELSIF stud_num_grade >= 80 THEN
        stud_char_grade := 'B';
        stud_status := 'passed';
    ELSIF stud_num_grade >= 70 THEN
        stud_char_grade := 'C';
        stud_status := 'passed';
    ELSIF stud_num_grade >= 60 THEN
        stud_char_grade := 'D';
        stud_status := 'passed';
    ELSE
        stud_char_grade := 'F';
        stud_status := 'failed';
    END IF;

    -- Update the grade and status columns in the ExamResults table
    UPDATE examsmanager.ExamResults
    SET grade = stud_char_grade,
        status = stud_status
    WHERE id = ex_id;

    -- Commit the transaction to save changes
    COMMIT;

    -- Return the computed grade
    RETURN stud_char_grade;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Error: ExamResults ID not found';
    WHEN OTHERS THEN
        RETURN 'Error: An unexpected error occurred';
END grade_calc;


SET SERVEROUTPUT ON;

DECLARE
    result_grade VARCHAR2(2);
BEGIN
    result_grade := grade_calc(2);
    DBMS_OUTPUT.PUT_LINE('Calculated Grade: ' || result_grade);
END;
-------------------------------------------------------------------------------------->Feature 3 => Issues warnings for students who failed two or more courses
CREATE SEQUENCE warnings_seq --> we here create a seq of ID's to insert in the table starting from 1 the seq is like an arr

START WITH 1 
INCREMENT BY 1;
----------------------------
set SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE issue_warnings IS
BEGIN
    FOR student_rec IN (
        SELECT student_id
        FROM User1.Register r
        JOIN examsmanager.ExamResults er ON r.id = er.registration_id
        WHERE er.status = 'failed'
        GROUP BY student_id
        HAVING COUNT(*) >= 2
    ) LOOP

        INSERT INTO examsmanager.Warnings (id, student_id, warning_reason, warning_date)
        VALUES (warnings_seq.NEXTVAL, student_rec.student_id, 'Failed two or more courses', SYSDATE);
    END LOOP;
END;
BEGIN
    issue_warnings;
END;
select * from examsmanager.warnings;
--------------------------------------------------------------------------------------> Feature 4 :) "INSERTION PART" => Logs an audit entry when a registration record is inserted.
CREATE SEQUENCE audit_trail_seq START WITH 1 INCREMENT BY 1; --> we here create a seq of ID's to insert in the table starting from 1 the seq is like an arr

CREATE OR REPLACE TRIGGER register_insert
BEFORE
INSERT
ON User1.Register
FOR EACH ROW
BEGIN
    INSERT INTO ExamsManager.AuditTrail (
        id,
        table_name,
        operation,
        old_data,
        new_data,
        timestamp
    ) VALUES (
        audit_trail_seq.NEXTVAL, --> we here use a sequence of ID's start from 1 and moving to the next value with .NEXTVAL
        'Register',
        'INSERT',
        NULL,
        'Student ID: ' || :NEW.student_id || ', Course ID: ' || :NEW.course_id,
        CURRENT_TIMESTAMP
    );
END;
--------------------------------------------------------------------------------------> Feature 4 :) "DELETION PART" => مLogs an audit entry when a registration record is deleted.
CREATE OR REPLACE TRIGGER register_delete
BEFORE
DELETE
ON User1.Register
FOR EACH ROW
BEGIN
    INSERT INTO ExamsManager.AuditTrail (
        id,
        table_name,
        operation,
        old_data,
        new_data,
        timestamp
    ) VALUES (
        audit_trail_seq.NEXTVAL,--> we here use a sequence of ID's start from 1 and moving to the next value with .NEXTVAL
        'Register',
        'DELETE',
        'Student ID: ' || :OLD.student_id || ', Course ID: ' || :OLD.course_id,
        NULL,
        CURRENT_TIMESTAMP
    );
END;
INSERT INTO User1.Register (id, student_id, course_id) VALUES (100, 2, 1);
SELECT * FROM User1.register;
SELECT * FROM examsmanager.audittrail;
---------------------------------------------------------------------------------------- Cursor for Course Performance Report (Feature 5) =>  Generates a performance report, showing the number of students who passed and failed a course.
SET SERVEROUTPUT ON
DECLARE
    v_course_id NUMBER := 3;  -- Replace 3 with the desired course_id
    CURSOR course_performance_cursor IS
        SELECT r.student_id, er.grade, er.status
        FROM user1.Register r
        JOIN examsmanager.ExamResults er ON r.id = er.registration_id
        WHERE r.course_id = v_course_id;

    v_student_id user1.Register.student_id%TYPE; 
    v_grade examsmanager.ExamResults.grade%TYPE;
    v_status examsmanager.ExamResults.status%TYPE;
    v_pass_count NUMBER := 0;
    v_fail_count NUMBER := 0;
     v_student_found BOOLEAN := FALSE; 
BEGIN
    OPEN course_performance_cursor; 

    LOOP
        FETCH course_performance_cursor INTO v_student_id, v_grade, v_status;
        EXIT WHEN course_performance_cursor%NOTFOUND;

        v_student_found := TRUE;

        IF v_status = 'passed' THEN
            v_pass_count := v_pass_count + 1;
        ELSE
            v_fail_count := v_fail_count + 1;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_student_id || 
                             CHR(10) ||
                             'Grade: ' || v_grade || ', Status: ' || v_status ||
                             CHR(10));
    END LOOP;

    CLOSE course_performance_cursor;

    IF NOT v_student_found THEN
        DBMS_OUTPUT.PUT_LINE('No students are registered for this course.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total Pass: ' || v_pass_count);
        DBMS_OUTPUT.PUT_LINE('Total Fail: ' || v_fail_count);
    END IF;
END;
--------------------------------------------------------------------------------------------------- Exam Schedule Management (Feature 6) => Displays the exam schedule for a specific course
SET SERVEROUTPUT ON;

DECLARE
    v_course_id NUMBER := 1;  -- Replace 1 with the desired course ID
    CURSOR exam_schedule_cursor IS
        SELECT e.exam_date, e.exam_type, c.name
        FROM examsmanager.Exams e
        JOIN user1.Courses c ON e.course_id = c.id
        WHERE e.course_id = v_course_id;

    v_exam_date examsmanager.Exams.exam_date%TYPE;
    v_exam_type examsmanager.Exams.exam_type%TYPE;
    v_course_name user1.Courses.name%TYPE;
    v_exam_found BOOLEAN := FALSE;
BEGIN
    OPEN exam_schedule_cursor; 

    LOOP
        -- Fetch data into variables فthat we declared above
        FETCH exam_schedule_cursor INTO v_exam_date, v_exam_type, v_course_name;
        EXIT WHEN exam_schedule_cursor%NOTFOUND;  -- Exit the loop if no more rows

        v_exam_found := TRUE;

        -- Display the exam details
        DBMS_OUTPUT.PUT_LINE('Course: ' || v_course_name || 
                             CHR(10) || 'Exam Date: ' || TO_CHAR(v_exam_date, 'DD-MON-YYYY') || 
                             CHR(10) || 'Exam Type: ' || v_exam_type || 
                             CHR(10));
    END LOOP;

    -- Display a message if no exams are found
    IF NOT v_exam_found THEN
        DBMS_OUTPUT.PUT_LINE('No exams are scheduled for the specified course.');
    END IF;

    CLOSE exam_schedule_cursor;
END;


-------------------------------------------------------------------------------------->Feature 7 => Updates grades for multiple exams in a single transaction and rolls back if any error occurs.
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status)
VALUES (101, 1, 'D', 'failed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status)
VALUES (102, 2, 'F', 'failed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status)
VALUES (103, 3, 'E', 'failed');
INSERT INTO examsmanager.ExamResults (id, registration_id, grade, status) --->Testing 
VALUES (104, 7, 'E', 'failed');
select * from examsmanager.examresults;
SET SERVEROUTPUT ON;
DECLARE
    TYPE reg_ids_type IS TABLE OF NUMBER;
    TYPE grades_type IS TABLE OF CHAR(1);
    v_reg_ids reg_ids_type := reg_ids_type(1, 2, 3);
    --v_grades grades_type := grades_type('B', 'A'); => this is wrong ya bro
    v_grades grades_type := grades_type('B', 'A', 'C');
    i PLS_INTEGER;
    error_occurred EXCEPTION;
BEGIN
    IF v_reg_ids.COUNT != v_grades.COUNT THEN
        RAISE error_occurred;
    END IF;

    FOR i IN 1 .. v_reg_ids.COUNT LOOP
        BEGIN
            UPDATE examsmanager.ExamResults
            SET grade = v_grades(i)
            WHERE registration_id = v_reg_ids(i);

            IF SQL%ROWCOUNT = 0 THEN
                RAISE error_occurred;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE;
        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('All grades updated successfully.');
EXCEPTION
    WHEN error_occurred THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error occurred. Transaction rolled back.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected error occurred. Transaction rolled back.');
END;

--------------------------------------------------------------------------------------> Feature 8 => Suspends students who have received three or more warnings.
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE SuspendStudents IS
BEGIN
    FOR student_rec IN (
        SELECT student_id
        FROM Examsmanager.Warnings
        GROUP BY student_id
        HAVING COUNT(*) >= 3
    ) LOOP
        UPDATE User1.Students
        SET academic_status = 'suspended'
        WHERE id = student_rec.student_id;

        INSERT INTO examsmanager.AuditTrail (id, table_name, operation, old_data, new_data)
        VALUES (
            audit_trail_seq.NEXTVAL,
            'Students',
            'UPDATE',
            'academic_status = active',
            'academic_status = suspended'
        );
    END LOOP;
END ;
BEGIN
    issue_warnings;
END;
select * from examsmanager.AuditTrail;