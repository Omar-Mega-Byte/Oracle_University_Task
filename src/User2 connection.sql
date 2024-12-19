--------------------------------------------------------------------------------------------------------------
INSERT INTO User1.Students (id, name, academic_status, total_credits) VALUES (1, 'Mohamed', 'suspended', 91);

INSERT INTO User1.Students (id, name, academic_status, total_credits) VALUES (2, 'Ali', 'active', 85);

INSERT INTO User1.Students (id, name, academic_status, total_credits) VALUES (3, 'Omar', 'suspended', 92);

INSERT INTO User1.Students (id, name, academic_status, total_credits) VALUES (4, 'Ahmed', 'active', 98);

INSERT INTO User1.Students (id, name, academic_status, total_credits) VALUES (5, 'Refaat', 'active', 80);
------------------------------------------------------------------------------------------------------------
INSERT INTO User1.Professors (id, name, department) VALUES (1, 'Elsaeed', 'CS');

INSERT INTO User1.Professors (id, name, department) VALUES (2, 'Ghoniem', 'AI');

INSERT INTO User1.Professors (id, name, department) VALUES (3, 'Shmardan', 'IT');
------------------------------------------------------------------------------------
INSERT INTO User1.Courses (id, name, professor_id, credit_hours) VALUES (1, 'DataStructures', 1, 3);

INSERT INTO User1.Courses (id, name, professor_id, credit_hours) VALUES (2, 'Databases2', 2, 3);

INSERT INTO User1.Courses (id, name, professor_id, credit_hours) VALUES (3, 'Algorithms', 3, 3);

INSERT INTO User1.Courses (id, name, professor_id, credit_hours, prerequisite_course_id) VALUES (4, 'Ai', 1, 3, 1);

INSERT INTO User1.Courses (id, name, professor_id, credit_hours, prerequisite_course_id) VALUES (5, 'English', 2, 2, 2);
----------------------------------------------------------------------------------------------
INSERT INTO User1.Register (id, student_id, course_id) VALUES (1, 4, 3);

INSERT INTO User1.Register (id, student_id, course_id) VALUES (2, 1, 3);

INSERT INTO User1.Register (id, student_id, course_id) VALUES (3, 2, 1);

INSERT INTO User1.Register (id, student_id, course_id) VALUES (4, 5, 2);

INSERT INTO User1.Register (id, student_id, course_id) VALUES (5, 3, 4);

INSERT INTO User1.Register (id, student_id, course_id) VALUES (6, 1, 1);

----------------------------------------------------------------------------------------------> Feature 10,11 (Continued)
INSERT INTO User1.Register (id, student_id, course_id)
VALUES (7, 1, 2); -- Referencing the same student locked in Session 1 (Which is User1 updates)

SELECT
    b.sid AS "Blocking Session",
    w.sid AS "Waiting Session",
    b.username AS "Blocking User",
    w.username AS "Waiting User",
    b.sql_id AS "Blocking SQL",
    w.sql_id AS "Waiting SQL"
FROM
    v$session b, v$session w
WHERE b.username IS NOT NULL and w.username IS NOT NULL;


--UPDATE User1.Students
--SET academic_status = 'suspended'
--WHERE id = 1;

select * from User1.register;
select * from User1.students;


DELETE FROM User1.Register
WHERE id = 7 AND student_id = 1 AND course_id = 2;

-- Wait until Session 1 releases the lock
 COMMIT; -- Uncomment this after Session 1 commits
----------------------------------------------------------------------------------------------
BEGIN
    LOCK TABLE User1.Register IN EXCLUSIVE MODE;
    UPDATE User1.Register SET course_id = 2 WHERE id = 1;
    COMMIT;
END;
----------------------------------------------------------------------------------------------
SELECT * FROM User1.Students;
SELECT * FROM User1.Courses;
SELECT * FROM User1.Professors;
SELECT * FROM User1.Register;
