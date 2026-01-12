DROP DATABASE IF EXISTS insurancek;
CREATE DATABASE insurancek;
USE insurancek;

CREATE TABLE IF NOT EXISTS personk (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE IF NOT EXISTS cark (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE IF NOT EXISTS accidentk (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE IF NOT EXISTS ownsk (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES personk(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES cark(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participatedk (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES personk(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES cark(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accidentk (report_no)
);

INSERT INTO person VALUES
("D111", "khushi", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Bharath", "Udaygiri, Mysuru"),
("D444", "Leo", "Rajivnagar, Mysuru"),
("D555", "Bunty", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "porsche", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);



-- Find the total number of people who owned a car that were involved in accidents in 2021
SELECT COUNT(DISTINCT P.driver_id) AS total_owners
FROM personk P
JOIN ownsk O ON P.driver_id = O.driver_id
JOIN participatedk PA ON O.driver_id = PA.driver_id AND O.reg_no = PA.reg_no
JOIN accidentk A ON PA.report_no = A.report_no
WHERE YEAR(A.accident_date) = 2021;

-- Find the number of accident in which cars belonging to smith were involved

select COUNT(distinct a.report_no)
from accidentk a
where exists 
(select * from personk p, participatedk ptd where p.driver_id=ptd.driver_id and p.driver_name="Smith" and a.report_no=ptd.report_no);

-- Add a new accident to the database

insert into accidentk values
(45562, "2024-04-05", "Mandya");
delete from cark
where model="Mazda" and reg_no in
(select cark.reg_no from personk p, ownsk o where p.driver_id=o.driver_id and o.reg_no=cark.reg_no and p.driver_name="Smith");
insert into participatedk values
("D222", "KA-21-BD-4728", 45562, 50000);


-- Delete the Mazda belonging to Smith

delete from cark
where model="Mazda" and reg_no in
(select cark.reg_no from personk p, ownsk o where p.driver_id=o.driver_id and o.reg_no=cark.reg_no and p.driver_name="Smith");


-- Update the damage amount for the car with reg_no of KA-09-MA-1234 in the accident with report_no 65738

update participatedk set damage_amount=10000 where report_no=65738 and reg_no="KA-09-MA-1234";

-- View that shows models and years of car that are involved in accident

create view CarskInAccident as
select distinct model, c_year
from cark c, participatedk p
where c.reg_no=p.reg_no;

select * from CarskInAccident;

-- A trigger that prevents a driver from participating in more than 2 accidents in a given year.

DELIMITER //

CREATE TRIGGER PreventParticipationk
BEFORE INSERT ON participatedk
FOR EACH ROW
BEGIN
    DECLARE accYear INT;

    -- Get the year of the accident the driver is being inserted into
    SELECT YEAR(accident_date) INTO accYear
    FROM accidentk
    WHERE report_no = NEW.report_no;

    -- Check how many accidents the driver has this year
    IF (
        SELECT COUNT(*)
        FROM participatedk p
        JOIN accidentk a ON p.report_no = a.report_no
        WHERE p.driver_id = NEW.driver_id
          AND YEAR(a.accident_date) = accYear
    ) >= 3 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents in the same year';

    END IF;
END//

DELIMITER ;

SELECT p.driver_id, a.report_no, YEAR(a.accident_date) AS year
FROM participatedk p
JOIN accidentk a ON p.report_no = a.report_no
ORDER BY driver_id, year;

INSERT INTO accidentk VALUES (22345, '2021-05-10', 'Mysuru');
INSERT INTO participatedk VALUES ("D222", "KA-21-BD-4728", 22345, 9000);
INSERT INTO accidentk VALUES (22346, '2021-11-02', 'Mysuru');
INSERT INTO participatedk VALUES ("D222", "KA-21-BD-4728", 22346, 6000);

INSERT INTO participatedk VALUES
("D222", "KA-20-AB-4223", 66666, 20000);