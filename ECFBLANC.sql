--1 Combien y-a-t-il d'enregistrements dans les tables
--customers, employees, offices, orders, payments et products ? 

select COUNT (*) FROM customers

SELECT COUNT(*) FROM employees

SELECT COUNT(*) FROM offices

SELECT COUNT(*) FROM orders

SELECT COUNT(*) FROM payments

SELECT COUNT(*) FROM products


--2 Lister par quantit� (quantityInStock) d�croissante les productName
--de la table des produits (products) contenant "Harley". 
select quantityInStock, productName from products
where productName like '%Harley%'
order by quantityInStock desc

--3 Lister par le pr�nom en ordre croissant dans la table des clients
--(customers) les clients dont le pr�nom a un a en deuxi�me position. 

select contactFirstName from customers
where contactFirstName like '_a%'
order by contactFirstName asc


--4 Combien y en a-t-il ? 

select count (*) from customers
where contactFirstName like '_a%'


--5 Dans la table products dont nous voulons n'afficher que productName et
--buyPrice sous les d�nominations respectives de "Les articles" et "Les prix";
--lister les articles dont les prix sont compris entre 50 et 65. 

select productName as 'Les articles', buyPrice as 'Les prix'
from products
where buyPrice between 50 and 65


--6 Afficher la somme, que vous nommerez "Total [07/2004]", et qui est la somme de
--tous les paiements effectu�s dans la table payments depuis le 1 juillet 2004. 

select sum(amount) as 'Total [07/2004]' from payments
where paymentDate >='2004-07-01'


--7 S�lectionner dans les d�tails de commande (orderDetails), les commandes dont la
--quantit� est sup�rieur ou �gale � 50 que l'on veut grouper par num�ro d'ordre. 

select orderNumber, quantityOrdered from orderdetails
where quantityOrdered >=50
group by orderNumber, quantityOrdered


--8 S�lectionner les clients (customerName) qui n'ont pas encore
--pass� commande et trier par ordre alphab�tique ascendant. 
select customers.customerNumber
from customers
inner join orders
on customers.customerNumber=orders.customerNumber
where [status] = 'cancelled'
order by customerName


--9. Combien d'employ�s (Nom, prenom, employeeNumber, jobTitle) ne sont
--rattach�s � aucun bureau (officeCode) ?

select count (*) jobTitle from employees
where officeCode = NULL


--10. Combien y-a-t-il de villes diff�rentes dans la table customers ?

select count(distinct city) from customers


--11. Quel est le nom et le num�ro du client qui a pay� le plus dans la table payments.On
--souhaite avoir la somme totale r�ellement pay�e pour chaque client dont on ne veut que
--le nom (pas le num�ro).

SELECT TOP(1) customerName, SUM(amount) from customers
JOIN payments ON customers.customerNumber = payments.customerNumber
group by customerName
order by SUM(amount) DESC


--12. Dans la table des produits (products), nous voulons la quantit� command�e, qui se
--trouve dans les d�tails des ordres (orderDetails), totale, et la somme des ventes,
--depuis le 01/01/2005, class�s par ligne de produit (productLine).

select quantityOrdered from products
join orderdetails
on products.productCode=orderdetails.productCode
join orders
on orders.orderNumber=orderdetails.orderNumber
where orderDate > '2005-01-01'
order by productLine

--13. Afficher les identifiants, les dates et status des commandes, le nom du client ayant
--pass� commande, ainsi que le nom, le code et la quantit� d'articles command�.


select orders.orderNumber, orders.orderDate, orders.[status], customers.contactFirstName,
customers.customerName, products.productName, products.productCode,
orderdetails.quantityOrdered from customers
join orders
on customers.customerNumber=orders.customerNumber
join orderdetails
on orders.orderNumber=orderdetails.orderNumber
join products
on orderdetails.productCode=products.productCode


--14. � partir des tables customers, employees, offices, orders, orderDetails, products
--afficher le nom du client, la ville et le pays du bureau, le pr�nom, le nom et
--le poste occup� par l'employ�, les articles command�s, leur quantit�, la ligne de produit
--et le prix d'achat.

select customerName as 'nom du client', offices.city as 'ville succursale',
offices.country as 'pays succursale', employees.firstName as 'pr�nom employ�',
employees.lastName as 'nom employ�', employees.jobTitle as 'poste occup�',
products.productName as 'articles command�s', products.quantityInStock as 'stock disponible',
products.productLine 'ligne produit', products.buyPrice "prix d'achat" from customers
join orders
on customers.customerNumber=orders.customerNumber
join orderdetails
on orders.orderNumber=orderdetails.orderNumber
join products
on orderdetails.productCode=products.productCode
join employees
on customers.salesRepEmployeeNumber=employees.employeeNumber
join offices
on employees.officeCode=offices.officeCode


--15. Cr�er un m�canisme qui se d�clenche lors de l'enregistrement d'une commande
--permettant la mise � jour de la quantit� en stock du (ou des) article(s)
--dans la table products.

create trigger RECCOM
on orderdetails
for insert
as begin update products set quantityInStock=quantityInStock - quantityOrdered
from products inner join inserted
on inserted.productCode=products.productCode
end


--16. R�cup�rer le dernier orderNumber. Donner le chiffre et la requ�te.
select top (1) orderNumber from orderdetails
order by orderNumber desc
--r�ponse: 10426


--17. R�cup�rer la quantit� en stock pour l'article S10_1949 dans la table products.
--Donner le chiffre et la requ�te.
select quantityInStock from products
where productCode like 'S10_1949'
--r�ponse: 7275


--18. Ins�rer une nouvelle commande. Ecrire la requ�te
--L'ordre:
--Num�ro d'ordre : le dernier orderNumber (cf. B) + 1
--Date de la commande : date du jour
--Date requise : date du jour + 7
--Date d'envoi : date du jour +5
--Status : In process
--Commentaire : Test du trigger
--Num�ro client : 103 

insert into orders (orderNumber, orderDate, requiredDate, shippedDate,
[status], comments, customerNumber)
values ((select top (1) orderNumber from orderdetails
order by orderNumber desc)+1, getdate(), getdate()+7, getdate()+15, 'In process','Test du trigger', 103)


--19. Ins�rer un d�tail de commande. Ecrire la requ�te.
--Le d�tail de l'ordre
--Num�ro d'ordre : le dernier orderNumber (cf. B) + 1
--Le code du produit : S10_1949
--Quantit� command�e : 10
--Le prix pour chaque article : 55.25
--Num�ro de ligne de la commande : 1

insert into orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
values ((select top (1) orderNumber from orderdetails
order by orderNumber desc), 'S10_1949', 10, 55.25, 1) 


--20 Cr�er une proc�dure stock�e � affiche � prenant en param�tre un customerNumber
--et regroupant sous le nom du client (customerName) le pr�nom et le nom du contact
--contactFirstName et contactLastName), la ville (city) et le pays (country) du client,
--le montant (amount) total des achats et la date du dernier paiement (paymentDate).

create procedure affiche @var1 numeric(11,0)
as
select customerName, contactFirstName, contactLastName, city, country,
amount, paymentDate
from customers
join payments
on customers.customerNumber=payments.customerNumber
where customers.customerNumber=@var1  


--Qu'affiche la commande suivante ?
--EXEC affiche(167);

exec affiche 167

