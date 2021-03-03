DROP SCHEMA IF EXISTS jd19z;
CREATE SCHEMA IF NOT EXISTS jd19z;
SHOW WARNINGS;
USE jd19z;

DROP TABLE IF EXISTS person;
CREATE TABLE IF NOT EXISTS person
(
    per_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_ssn BINARY(64) NULL,
    per_salt binary(64) null COMMENT '*only* demo purposes - do *not* use *salt* in the name!',
    per_fname VARCHAR(15) NOT NULL,
    per_lname VARCHAR(30) NOT NULL,
    per_street VARCHAR(30) NOT NULL,
    per_city VARCHAR(30) NOT NULL,
    per_state CHAR(2) NOT NULL,
    per_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    per_email VARCHAR(100) NOT NULL,
    per_dob DATE NOT NULL,
    per_type ENUM('a','c','j') NOT NULL,
    per_notes VARCHAR(255) NULL,
    PRIMARY KEY (per_id),
    UNIQUE INDEX ux_per_ssn (per_ssn ASC)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS attorney;
CREATE TABLE IF NOT EXISTS attorney
(
    per_id SMALLINT UNSIGNED NOT NULL,
    aty_start_date DATE NOT NULL,
    aty_end_date DATE NULL DEFAULT NULL,
    aty_hourly_rate DECIMAL(5,2) UNSIGNED NOT NULL,
    aty_years_in_practice TINYINT NOT NULL,
    aty_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),

    CONSTRAINT fk_attorney_person
        FOREIGN KEY (per_id)
        REFERENCES person (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS client;
CREATE TABLE IF NOT EXISTS client
(
    per_id SMALLINT UNSIGNED NOT NULL,
    cli_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_client_person
        FOREIGN KEY (per_id)
        REFERENCES person (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS court;
CREATE TABLE IF NOT EXISTS court
(
    crt_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    crt_name VARCHAR(45) NOT NULL,
    crt_street VARCHAR(30) NOT NULL,
    crt_city VARCHAR(30) NOT NULL,
    crt_state CHAR(2) NOT NULL,
    crt_zip INT(9) UNSIGNED ZEROFILL NOT NULL,
    crt_phone BIGINT NOT NULL,
    crt_email VARCHAR(100) NOT NULL,
    crt_url VARCHAR(100) NOT NULL,
    crt_notes VARCHAR(255) NULL,
    PRIMARY KEY (crt_id)
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS judge;
CREATE TABLE IF NOT EXISTS judge
(
    per_id SMALLINT UNSIGNED NOT NULL,
    crt_id TINYINT UNSIGNED NULL DEFAULT NULL,
    jud_salary DECIMAL(8,2) NOT NULL,
    jud_years_in_practice TINYINT UNSIGNED NOT NULL,
    jud_notes VARCHAR(255) NULL DEFAULT NULL,
    PRIMARY KEY (per_id),

    INDEX idx_per_id (per_id ASC),
    INDEX idx_crt_id (crt_id ASC),

        CONSTRAINT fk_judge_person
        FOREIGN KEY (per_id)
        REFERENCES person (per_id)
        ON DELETE NO ACTION
        ON UPDATE  CASCADE,

        CONSTRAINT fk_judge_court
        FOREIGN KEY (crt_id)
        REFERENCES court (crt_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS judge_hist;
CREATE TABLE IF NOT EXISTS judge_hist
(
    jhs_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    jhs_crt_id TINYINT NULL,
    jhs_date timestamp NOT NULL default current_timestamp(),
    jhs_type enum('i','u','d') NOT NULL default 'i',
    jhs_salary DECIMAL(8,2) NOT NULL,
    jhs_notes VARCHAR(255) NULL,
    PRIMARY KEY (jhs_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_judge_hist_judge
        FOREIGN KEY (per_id)
        REFERENCES judge (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS `case`;
CREATE TABLE IF NOT EXISTS `case`
(
    cse_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    cse_type VARCHAR(45) NOT NULL,
    cse_description TEXT NOT NULL,
    cse_start_date DATE NOT NULL,
    cse_end_date DATE NULL,
    cse_notes VARCHAR(255) NULL,
    PRIMARY KEY (cse_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_court_case_judge
        FOREIGN KEY (per_id)
        REFERENCES judge (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS bar;
CREATE TABLE IF NOT EXISTS bar
(
    bar_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    bar_name VARCHAR(45) NOT NULL,
    bar_notes VARCHAR(255) NULL,
    PRIMARY KEY (bar_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_bar_attorney
        FOREIGN KEY (per_id)
        REFERENCES attorney (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS specialty;
CREATE TABLE IF NOT EXISTS specialty
(
    spc_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    spc_type VARCHAR(45) NOT NULL,
    spc_notes VARCHAR(255) NOT NULL,
    PRIMARY KEY (spc_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_specialty_attorney
        FOREIGN KEY (per_id)
        REFERENCES attorney (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS assignment;
CREATE TABLE IF NOT EXISTS assignment
(
    asn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_cid SMALLINT UNSIGNED NOT NULL,
    per_aid SMALLINT UNSIGNED NOT NULL,
    cse_id SMALLINT UNSIGNED NOT NULL,
    asn_notes VARCHAR(255) NULL,
    PRIMARY KEY (asn_id),

    INDEX idx_per_cid (per_cid ASC),
    INDEX idx_per_aid (per_aid ASC),
    INDEX idx_cse_id (cse_id ASC),

    UNIQUE INDEX ux_per_cid_per_aid_cse_id (per_cid ASC, per_aid ASC, cse_id ASC),

        CONSTRAINT fk_assign_case
        FOREIGN KEY (cse_id)
        REFERENCES `case` (cse_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
        
        CONSTRAINT fk_assignment_client
        FOREIGN KEY (per_cid)
        REFERENCES client (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
        
        CONSTRAINT fk_assignment_attorney
        FOREIGN KEY (per_aid)
        REFERENCES attorney (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

DROP TABLE IF EXISTS phone;
CREATE TABLE IF NOT EXISTS phone
(
    phn_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    per_id SMALLINT UNSIGNED NOT NULL,
    phn_num BIGINT UNSIGNED NOT NULL,
    phn_type ENUM('h','c','w','f') NOT NULL COMMENT 'home, cell, work, fax',
    phn_notes VARCHAR(255) NULL,
    PRIMARY KEY (phn_id),

    INDEX idx_per_id (per_id ASC),

        CONSTRAINT fk_phone_person
        FOREIGN KEY (per_id)
        REFERENCES person (per_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)
ENGINE = InnoDB
DEFAULT CHARACTER SET=utf8
COLLATE = utf8_unicode_ci;

<--INSERTS-->

START TRANSACTION;

INSERT INTO person
(per_id, per_ssn, per_salt, per_fname, per_lname, per_street, per_city, per_state, per_zip, per_email, per_dob, per_type, per_notes)
VALUES
(NULL, NULL, NULL, 'Steve', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 324402222, 'fake@gmai.com', '1923-10-03', 'c', NULL),
(NULL, NULL, NULL, 'Frank', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 003208440, 'fake@gmai.com', '1900-11-03', 'c', NULL),
(NULL, NULL, NULL, 'Bill', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 102862341, 'fake@gmai.com', '1958-10-03', 'c', NULL),
(NULL, NULL, NULL, 'Justin', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 032084409, 'fake@gmai.com', '1969-08-03', 'c', NULL),
(NULL, NULL, NULL, 'Joel', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 286234178, 'fake@gmai.com', '1999-08-03', 'c', NULL),
(NULL, NULL, NULL, 'John', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 902638332, 'fake@gmai.com', '1911-05-03', 'a', NULL),
(NULL, NULL, NULL, 'Randy', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 022348890, 'fake@gmai.com', '1905-05-03', 'a', NULL),
(NULL, NULL, NULL, 'Rando', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 872638332, 'fake@gmai.com', '1900-05-03', 'a', NULL),
(NULL, NULL, NULL, 'Brandi', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 002348890, 'fake@gmai.com', '1825-06-03', 'a', NULL),
(NULL, NULL, NULL, 'Nicole', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 562638332, 'fake@gmai.com', '1800-06-03', 'a', NULL),
(NULL, NULL, NULL, 'Brandon', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 000219932, 'fake@gmai.com', '1869-09-03', 'j', NULL),
(NULL, NULL, NULL, 'Rake', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 332048823, 'fake@gmai.com', '1978-09-03', 'j', NULL),
(NULL, NULL, NULL, 'Rolo', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 870219932, 'fake@gmai.com', '1922-03-03', 'j', NULL),
(NULL, NULL, NULL, 'VScode', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 672048823, 'fake@gmai.com', '1947-03-03', 'j', NULL),
(NULL, NULL, NULL, 'Franky', 'Rogers', '437 Southern Drive', 'Rochester', 'NY', 320219932, 'fake@gmai.com', '1910-03-03', 'j', NULL);

COMMIT;

START TRANSACTION;

INSERT INTO phone
(phn_id, per_id, phn_num, phn_type, phn_notes)
VALUES
(NULL, 1, 8032288827, 'c', NULL),
(NULL, 2, 2052338293, 'h', NULL),
(NULL, 3, 1034325598, 'w', 'has two office numbers'),
(NULL, 4, 6402338494, 'w', NULL),
(NULL, 5, 5508329842, 'f', 'fax number not currently working'),
(NULL, 6, 8202052203, 'c', NULL),
(NULL, 7, 4008338294, 'h', 'prefers home calls'),
(NULL, 8, 4008338294, 'w', NULL),
(NULL, 9, 7654328912, 'f', 'work fax number'),
(NULL, 10, 5463721984, 'h', NULL),
(NULL, 11, 4537821902, 'w', 'call during lunch'),
(NULL, 12, 7867821902, 'w', NULL),
(NULL, 13, 4537821654, 'c', NULL),
(NULL, 14, 3721821902, 'c', NULL),
(NULL, 15, 9217821945, 'f', NULL);

COMMIT;

START TRANSACTION;

INSERT INTO client(per_id, cli_notes)
VALUES
(1, NULL),
(2, NULL),
(3, NULL),
(4, NULL),
(5, NULL);

COMMIT;

START TRANSACTION;

INSERT INTO attorney
(per_id, aty_start_date, aty_end_date, aty_hourly_rate, aty_years_in_practice, aty_notes)
VALUES
(6, '2006-06-12', NULL, 85, 5, NULL),
(7, '2003-08-20', NULL, 130, 28, NULL),
(8, '2009-12-12', NULL, 70, 17, NULL),
(9, '2008-06-08', NULL, 78, 13, NULL),
(10, '2011-09-12', NULL, 60, 24, NULL);

COMMIT;

INSERT INTO bar
(bar_id, per_id, bar_name, bar_notes)
VALUES
(NULL, 6, 'Florida Bar', NULL),
(NULL, 7, 'Alabama Bar', NULL),
(NULL, 8, 'Georgia Bar', NULL),
(NULL, 9, 'Michigan Bar', NULL),
(NULL, 10, 'South Carolina Bar', NULL),
(NULL, 6, 'Montana Bar', NULL),
(NULL, 7, 'Arizona Bar', NULL),
(NULL, 8, 'Nevada Bar', NULL),
(NULL, 9, 'New York Bar', NULL),
(NULL, 10, 'Miisiisippi Bar', NULL),
(NULL, 6, 'California Bar', NULL),
(NULL, 7, 'California Bar', NULL),
(NULL, 8, 'Illinois Bar', NULL),
(NULL, 9, 'Indiana Bar', NULL),
(NULL, 10, 'Illinois Bar', NULL),
(NULL, 6, 'Tallahasse Bar', NULL),
(NULL, 7, 'Ocala Bar', NULL),
(NULL, 8, 'Bay County Bar', NULL),
(NULL, 9, 'Cincinatti Bar', NULL);

COMMIT;

INSERT INTO specialty
(spc_id, per_id, spc_type, spoc_notes)
VALUES
(NULL, 6, 'business', NULL),
(NULL, 7, 'traffic', NULL),
(NULL, 8, 'bankruptcy', NULL),
(NULL, 9, 'insurnace', NULL),
(NULL, 10, 'judicial', NULL),
(NULL, 6, 'environmental', NULL),
(NULL, 7, 'criminal', NULL),
(NULL, 8, 'real estate', NULL),
(NULL, 9, 'malpractice', NULL);

COMMIT;

START TRANSACTION;

INSERT INTO court
(crt_id, crt_name, crt_street, crt_city, crt_state, crt_zip, crt_phone, crt_email, crt_url, crt_notes)
VALUES
(NULL, 'leon county circuit court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL),
(NULL, 'leon county circuit court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL),
(NULL, 'florida supreme court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL),
(NULL, 'orange county circuit court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL),
(NULL, 'leon county circuit court', '301 south monroe street', 'tallahassee', 'fl', 323035292, 8506065504, 'lccc@us.fl.gov', 'http://www.leoncountycircuitcourt.gov/', NULL);

COMMIT;

START TRANSACTION;

INSERT INTO judge
(per_id, crt_id, jud_salary, jud_years_in_practice, jud_notes)
VALUES
(11, 5, 150000, 10, NULL),
(12, 4, 185000, 3, NULL),
(13, 4, 135000, 2, NULL),
(14, 3, 170000, 6, NULL),
(15, 1, 120000, 1, NULL);

COMMIT;

START TRANSACTION;

INSERT INTO judge_hist
(jhs_id, per_id, jhs_crt_id, jhs_date, jhs_type, jhs_salary, jhs_notes)
VALUES
(NULL, 11, 3, '2009-01-16', 'i', 130000, NULL),
(NULL, 12, 2, '2010-01-16', 'i', 140000, NULL),
(NULL, 13, 5, '2000-01-16', 'i', 150000, NULL),
(NULL, 13, 4, '2005-01-16', 'i', 115000, NULL),
(NULL, 14, 4, '2008-01-16', 'i', 135000, NULL),
(NULL, 15, 1, '2011-01-16', 'i', 155000, NULL),
(NULL, 11, 5, '2010-01-16', 'i', 150000, NULL),
(NULL, 12, 4, '2012-01-16', 'i', 165000, NULL),
(NULL, 14, 3, '2009-01-16', 'i', 170000, NULL);

COMMIT;

START TRANSACTION;

INSERT INTO `case`
(cse_id, per_id, cse_type, cse_description, cse_start_date, cse_end_date, cse_notes)
VALUES
(NULL, 13, 'civil', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 12, 'criminal', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 14, 'criminal', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 11, 'civil', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 13, 'civil', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 14, 'criminal', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 12, 'criminal', 'client says blah blah', '2010-09-09', NULL, 'something illegal'),
(NULL, 15, 'civil', 'client says blah blah', '2010-09-09', NULL, 'something illegal');

COMMIT;

START TRANSACTION;

INSERT INTO assignment
(asn_id, per_cid, per_aid, cse_id, asn_notes)
VALUES
(NULL, 1, 6, 7, NULL),
(NULL, 2, 6, 6, NULL),
(NULL, 3, 7, 2, NULL),
(NULL, 4, 8, 2, NULL),
(NULL, 5, 9, 5, NULL),
(NULL, 1, 10, 1, NULL),
(NULL, 2, 6, 3, NULL),
(NULL, 3, 7, 8, NULL),
(NULL, 4, 8, 8, NULL),
(NULL, 5, 9, 8, NULL),
(NULL, 4, 10, 4, NULL);

COMMIT;

<--Securing Data-->

DROP PROCEDURE IF EXISTS CreatePersonSSN;
DELIMITER $$
CREATE PROCEDURE CreatePersonSSN()
BEGIN
    DECLARE x, y INT;
    SET x = 1;

    select count(*) into y from person;

    WHILE x <= y DO

        SET @salt=RANDOM_BYTES(64);
        SET @ran_num=FLOOR(RAND()*(999999999-111111111+1))+111111111;
        SET @ssn=unhex(sha2(concat(@salt, @ran_num), 512));

        update person
        set per_ssn=@ssn, per_salt=@salt
        where per_id=x;
    SET x = x + 1;

    END WHILE;
END$$
DELIMITER;
call CreatePersonSSN();

<--Views-->

drop VIEW if exists v_attorney_info;
CREATE VIEW v_attorney_info AS

    select
    concat(per_lname, ", ", per_fname) as name,
    concat(per_street, ", ", per_city, ", ", per_state, " ", per_zip) as address,
    TIMESTAMPDIFF(year, per_dob, now()) as age,
    CONCAT('$', FORMAT(aty_hourly_rate, 2)) as hourly_rate,
    bar_name, spc_type
    from person
        natural join attorney
        natural join bar
        natural join specialty
        order by per_lname;

drop procedure if exists sp_num_judges_born_by_month;
DELIMITER //
CREATE PROCEDURE sp_num_judges_born_by_month()
BEGIN
    select month(per_dob) as month, monthname(per_dob) as month_name, count(*) as count
    from person
    natural join judge
    group by month_name
    order by month;
END //
DELIMITER ;

drop procedure if exists sp_cases_and_judges;
DELIMITER //
CREATE PROCEDURE sp_cases_and_judges()
BEGIN
    select per_id, cse_id, cse_type, cse_description,
    concat(per_fname, " ", per_lname) as name,
    concat('(',substring(phn_num, 1, 3), ')', substring(phn_num, 4, 3), '-', substring(phn_num, 7, 4)) as judge_office_num,
    phn_type,
    jud_years_in_practice,
    cse_start_date,
    cse_end_date
from person
    natural join judge
    natural join `case`
    natural join phone
where per_type='j'
order by per_lname;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_judge_history_after_insert;
DELIMITER //
CREATE TRIGGER trg_judge_history_after_insert
AFTER INSERT ON judge
FOR EACH ROW
BEGIN
    INSERT INTO judge_hist
    (per_id, jhs_crt_id, jhs_date, jhs_type, jhs_salary, jhs_notes)
    VALUES
    (
        NEW.per_id, NEw.crt_id, current_timestamp(), 'i', NEW.jud_salary,
        concat("modifying user: ", user(), " Notes: ", New.jud_notes)
    );
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_judge_history_after_update;
DELIMITER //
CREATE TRIGGER trg_judge_history_after_update
AFTER UPDATE ON judge
FOR EACH ROW
BEGIN
    INSERT INTO judge_hist
    (per_id, jhs_crt_id, jhs_date, jhs_type, jhs_salary, jhs_notes)
    VALUES
    (
        NEW.per_id, NEW.crt_id, current_timestamp(), 'u', NEW.jud_salary,
        concat("modifying user: ", user(), " Notes: ", NEW.jud_notes)
    );
END //
DELIMITER ;

drop procedure if exists sp_add_judge_record;
DELIMITER //

CREATE PROCEDURE sp_add_judge_record()
BEGIN
    INSERT INTO judge
    (per_id, crt_id, jud_salary, jud_years_in_practice, jud_notes)
    VALUES
    (
        6, 1, 11000000, 0, concat("New judge was former attorney. ", "Modifying event  creator: ", current_user()
    );
END //

DELIMITER ;

DROP EVENT IF EXISTS one_time_add_judge;

DELIMITER //
CREATE EVENT IF NOT EXISTS one_time_add_judge
ON SCHEDULE
    AT NOW() + INTERVAL 5 SECOND
COMMENT 'adds a judge record only one-time'
DO
BEGIN
    CALL sp_add_judge_record();
END //

DELIMITER ;

DROP EVENT IF EXISTS remove_judge_history;

DELIMITER //
CREATE EVENT IF NOT EXISTS remove_judge_history
ON SCHEDULE
    EVERY 2 MONTH
STARTS NOW() + INTERVAL 3 WEEK
ENDS NOW() + INTERVAL 4 YEAR
COMMENT 'keeps only the first 100 judge records'
DO
BEGIN
    DELETE FROM judge_hist where jhs_id > 100;
END //

DELIMITER ;

DROP EVENT IF EXISTS remove_judge_history;