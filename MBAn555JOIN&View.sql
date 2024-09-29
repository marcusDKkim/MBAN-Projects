#Marcus Kim Homework 2 submission

use kimtay;
show tables;
#-Q1: List the ID, first name, and last name of each customer, 
	#together with the ID, first name, and last name of the sales rep who represents the customer
select cust_id, cust.first_name, cust.last_name, sr.rep_id, sr.first_name, sr.last_name
from customer as cust 
left outer join sales_rep as sr using (rep_id);
#-output: 12 rows returned 

#-Q2: List the ID, first name, and last name of each customer whose credit limit is $500, 
	#together with the ID, first name, and last name of the sales rep who represents the customer.
select cust_id, cust.first_name, cust.last_name, sr.rep_id, sr.first_name, sr.last_name
from customer as cust 
left outer join sales_rep as sr using (rep_id)
where cust.credit_limit > 500;
#-output: 4 rows returned

#-Q3: For every item on an invoice, list the invoice number, item ID, description, quantity ordered, quoted price, and unit price.
select il.invoice_num, il.item_id, item.description, il.quantity, il.quoted_price, item.price
from invoice_line as il 
join item using (item_id);
#-output: 12 rows returned

#-Q4: Find the description of each item included in invoice number 14233
select item.description 
from invoice_line 
inner join item using (item_id) 
where invoice_num = 14233;
#-output: 3 rows returned

#-Q5: Find the invoice number and invoice date for each invoice that contains item ID KH81.
	#You are asked to use the “IN” operator for answering this question.  
select invoice_num, inv.invoice_date 
from item 
join invoice_line as il using (item_id)
join invoices as inv using (invoice_num) 
where il.item_id IN ("KH81");  
#-output: 2 rows returned

#-Q6: Find the invoice number and invoice date for each invoice that includes an item stored in location C. 
	#Note that answering this question may require a nested subquery.
select inv.invoice_num, inv.invoice_date 
from invoices as inv
join invoice_line as il using (invoice_num)
join item using (item_id)
where location in (select location from item where location = "C");
#-output: 5 rows returned 
    
#-Q7: List the customer ID, invoice number, invoice date, and invoice total for each invoice with a total that exceeds $250. 
	#Assign the column name INVOICE_TOTAL to the column that displays invoice totals. Order the results by invoice number.
select cust.cust_id, il.invoice_num, inv.invoice_date, (il.quantity*il.quoted_price) as invoice_total
from customer as cust
join invoices as inv using (cust_id) 
join invoice_line as il using (invoice_num) 
having invoice_total > 250
order by il.invoice_num;
#-output: 3 rows returned
    
#-Q8: For each pair of customers located in the same city, display the customer ID, first name, last name, and city. 	
	#Note that a pair must be two different customers – A and A are not a pair, A and B is fine.   
SELECT c1.cust_id, c1.first_name, c1.last_name, c1.city,
       c2.cust_id AS pair_customer_id, c2.first_name AS pair_first_name, c2.last_name AS pair_last_name
FROM customer c1
JOIN customer c2 ON c1.city = c2.city AND c1.cust_id < c2.cust_id;
#-output: 7 rows returned

#-Q9: List the ID and names of each customer that is either represented by sales rep 10 or currently has invoices on file, or both. 
	#(Hint: use UNION operator).
select cust_id, customer.first_name, customer.last_name
from customer 
join sales_rep using (rep_id) 
where customer.rep_id = 10
UNION
select cust_id, customer.first_name, customer.last_name
from customer
join invoices using (cust_id);
#-output: 8 rows returned
    
#-Q10: Display the ID, first name, and last name for each customer, along with the invoice number, and invoice date for all invoices. 
	#Include all customers in the results. For customers that do not have invoices, omit the invoice number and invoice date. 
    #(Hint: this will require an outer join).
select cust_id, first_name, last_name, invoice_num, invoice_date
from customer 
left outer join invoices using (cust_id);
#-output: 14 rows returned 

#-Q11: List the invoice number and invoice date for each invoice that was created for James Gonzalez 
	#and that contains an invoice line for Wild Bird Food (25 lb).
select invoice_num, invoice_date 
from invoices
join customer using (cust_id) 
where first_name = "James" and last_name = "Gonzalez" 
UNION
select invoice_num, invoice_date
from invoices
join invoice_line using (invoice_num)
join item using (item_id)
where description = 'Wild Bird Food (25 lb)';
#-output: 3 rows returned
    
#-Q12: List the invoice number and invoice date for each invoice that was created for James Gonzalez 
	#but that does not contain an invoice line for Wild Bird Food (25 lb).
select invoice_num, invoice_date 
from invoices
join customer using (cust_id) 
where first_name = "James" and last_name = "Gonzalez" 
UNION
select invoice_num, invoice_date
from invoices
join invoice_line using (invoice_num)
join item using (item_id)
where description <> 'Wild Bird Food (25 lb)';
#-output: 7 rows returned 
    
#-Q13: List the sales rep ID and last name for each sales rep. Display the last name in uppercase letters. (Hint: use the UPPER function).
select rep_id, upper(last_name)
from sales_rep;
#-output: 4 rows reutrned 

#-Q14: List the item ID and price for all items. Round the price to the nearest whole dollar amount. (Hint: use the ROUND function).
select item_id, round(price,0) 
from item;
#-output: 15 rows returned 

#-Q15: For each invoice, list the date that is one month after the invoice date. Name this date NEXT_MONTH. 
	#(Hint: use the DATE_ADD function).
select DATE_ADD(invoice_date, INTERVAL 1 month) as NEXT_MONTH 
from invoices;
#-output: 8 rows returned

#-Q16: For each invoice, list the invoice number and the date that is seven days after the invoice date. Name this date NEXT_WEEK.
select invoice_num, DATE_ADD(invoice_date, INTERVAL 1 WEEK) as NEXT_WEEK
from invoices;
#-output: 8 rows returned 

#-Q17: For each invoice, list the invoice number, today’s date, the invoice date, and the number of days between the invoice date 
	#and today’s date. Name today’s date TODAYS_DATE and name the number of days between the invoice date and today’s date DAYS_PAST.
select invoice_num, CURDATE() as TODAYS_DATE, invoice_date, DATEDIFF(CURDATE(),invoice_date) as DAYS_PAST
from invoices;
#-output: 8 rows returned 
    
#-Q18: Write a MySQL procedure that takes a customer ID as input and displays the corresponding customer full name. 
	#Execute the procedure for customer id 125.
DELIMITER //
CREATE PROCEDURE CustomersNam(IN cid char(3))
BEGIN 
	select CONCAT(c.first_name, " ", c.last_name) as CustName 
    from customer as c where cust_id = cid;
END //
DELIMITER;
CALL CustomersNam(125);

#-Q19: Write a procedure for the same problem as above but with an Error Handler for 
	#when you ask for the name of a customer with a customer id that does not exist.
    
DELIMITER //
CREATE procedure CustomerFullName(IN cid char(3))
BEGIN
	DECLARE CustomName varchar(40);
    
    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
		SELECT "No Customers Found" as Message;
	END;
	
    select concat(c.first_name, " ", c.last_name) into CustomName
    from customer as c where cust_id = cid;
    
    if CustomName is not null then
		select CustomName as FULL_NAME;
	end if;
END //
DELIMITER ;

call CustomerFullName(125);
-- 'Joey Smith'

call CustomerFullName(799); 
-- 'No Customers Found
    
#-Q20: Open Ended: Write a stored procedure of your choice. Make sure that the stored procedure needs two inputs 
	#and it has error handling to manage any errors that may arise.
DELIMITER //
CREATE procedure MaxMinQuote(In itemsearch varchar(40), quote decimal(10,0))
BEGIN
	if exists(select item_id from item where description like concat('%', itemsearch, '%')) then
			select 
				description, 
				item_id, 
				Case 
					when quoted_price < price then quoted_price * quote
					else price * quote
				End as min_total,
				Case 
					when quoted_price < price then price * quote
					else quoted_price * quote
				End as max_total
			from item join invoice_line using(item_id)
			where description like concat('%', itemsearch, '%');
	else
		SELECT "No item Found" as Message;
	end if;
END //
DELIMITER ;

call MaxMinQuote("cat", 5) ;
-- 'Enclosed Cat Litter Station', 'CA75', '189.95', '199.95'

call MaxMinQuote("bird", 5) ;
-- 'Wild Bird Food (25 lb)','KH81','94.95','99.95'
-- 'Wild Bird Food (25 lb)','KH81','99.95','99.95'




