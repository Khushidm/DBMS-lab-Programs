drop database if exists order_processingk;
create database order_processingk;
use order_processingk;

create table if not exists Customersk (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table if not exists Ordersk (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customersk(cust_id) on delete cascade
);

create table if not exists Itemsk (
	item_id  int primary key,
	unitprice int not null
);

create table if not exists OrderItemsk (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Ordersk(order_id) on delete cascade,
	foreign key (item_id) references Itemsk(item_id) on delete cascade
);

create table if not exists Warehousesk (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table if not exists Shipmentsk (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Ordersk(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehousesk(warehouse_id) on delete cascade
);

INSERT INTO Customersk VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Ordersk VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Itemsk VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehousesk VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItemsk VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipmentsk VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");


SELECT * FROM Customersk;
SELECT * FROM Ordersk;
SELECT * FROM OrderItemsk;
SELECT * FROM Itemsk;
SELECT * FROM Shipmentsk;
SELECT * FROM Warehousesk;


-- List the Order# and Ship_date for all orders shipped from Warehouse# "w2"="0002".
select order_id,ship_date from Shipmentsk where warehouse_id=0002;

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#
select s.order_id,s.warehouse_id from Shipmentsk s where s.order_id in (select order_id from Ordersk where cust_id = (Select cust_id from Customersk where cname='Kumar'));

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt
select c.cname, COUNT(o.order_id) as no_of_orders, AVG(o.order_amt) as avg_order_amt
from Customersk c 
join Ordersk o ON c.cust_id=o.cust_id 
group by c.cust_id,c.cname;

-- Delete all orders for customer named "Kumar".
delete from Ordersk where cust_id = (select cust_id from Customersk where cname='Kumar');

-- Find the item with the maximum unit price.
select item_id,unitprice from Itemsk where unitprice=(select max(unitprice) from Itemsk);

--TRIGGER: updates order_amount based on quantity and unitprice of order_item

DELIMITER $$

CREATE TRIGGER updateorderAmtk
AFTER INSERT ON OrderItemsk
FOR EACH ROW
BEGIN
    UPDATE Ordersk
    SET order_amt = (
        SELECT SUM(oi.qty * i.unitprice)
        FROM OrderItemsk oi
        JOIN Itemsk i ON oi.item_id = i.item_id
        WHERE oi.order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END $$

DELIMITER ;
INSERT INTO OrderItemsk VALUES (1, 1, 5);
SELECT * FROM Ordersk WHERE order_id = 1;


-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 5.

create view ShipmentDatesFromWarehouse5 as
select order_id, ship_date
from Shipmentsk
where warehouse_id=0005;

select * from ShipmentDatesFromWarehouse5;