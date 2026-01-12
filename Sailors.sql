drop database if exists Sailorsk;

create database Sailorsk;
use Sailorsk;

create table if not exists Sailorsk(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table if not exists Boatk(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table if not exists reservesk(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailorsk(sid) on delete cascade,
	foreign key (bid) references Boatk(bid) on delete cascade
);

insert into Sailorsk values
(1,"khushi", 5.0, 40),
(2, "bharath", 5.0, 49),
(3, "riddhi", 9, 18),
(4, "bhavani", 2, 68),
(5, "Albert", 7, 19);


insert into Boatk values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reservesk values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

select * from Sailorsk;
select * from Boatk;
select * from reservesk;

-- Find the colours of the boats reserved by Albert
SELECT DISTINCT b.color 
from Sailorsk s, Boatk b, reservesk r 
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103

(select sid
from Sailorsk
where Sailorsk.rating>=8)
UNION
(select sid
from reservesk
where reservesk.bid=103);


-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order

select s.sname
from Sailorsk s
where s.sid not in 
(select s1.sid from Sailorsk s1, reservesk r1 where r1.sid=s1.sid and s1.sname like "%storm%")
and s.sname like "%storm%"
order by s.sname ASC;

-- Find the name of the sailors who have reserved all boats

select s.sname from Sailorsk s where not exists
	(select * from Boatk b where not exists
		(select * from reservesk r where r.sid=s.sid and b.bid=r.bid));


-- Find the name and age of the oldest sailor

select sname, age
from Sailorsk where age in (select max(age) from Sailorsk);

-- For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors

select b.bid, avg(s.age) as average_age
from Sailorsk s, Boatk b, reservesk r
where r.sid=s.sid and r.bid=b.bid and s.age>=40
group by bid
having 2<=count(distinct r.sid);


-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.

create view ReservedBoatsWithRatedSailork as
select distinct bname, color
from Sailorsk s, Boatk b, reservesk r
where s.sid=r.sid and b.bid=r.bid and s.rating=5;

select * from ReservedBoatsWithRatedSailork;


-- Trigger that prevents boats from being deleted if they have active reservation
drop trigger if exists ChechAndDelete;
DELIMITER //
create or replace trigger CheckAndDelete
before delete on Boat
for each row
BEGIN
	IF EXISTS (select * from reservesk where reservesk.bid=old.bid) THEN
		SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
	END IF;
END;//

DELIMITER ;

delete from Boat where bid=103; -- This gives error since boat 103 is reserved
