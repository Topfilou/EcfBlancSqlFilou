--1 Combien y-a-t-il d'enregistrements dans les tables
--customers, employees, offices, orders, payments et products ? 

select COUNT (*) FROM customers

SELECT COUNT(*) FROM employees

SELECT COUNT(*) FROM offices

SELECT COUNT(*) FROM orders

SELECT COUNT(*) FROM payments

SELECT COUNT(*) FROM products


--2 Lister par quantité (quantityInStock) décroissante les productName
--de la table des produits (products) contenant "Harley". 
select quantityInStock, productName from products
where productName like '%Harley%'
order by quantityInStock desc

--3 Lister par le prénom en ordre croissant dans la table des clients
--(customers) les clients dont le prénom a un a en deuxième position. 

select contactFirstName from customers
where contactFirstName like '_a%'
order by contactFirstName asc


--4 Combien y en a-t-il ? 

select count (*) from customers
where contactFirstName like '_a%'


--5 Dans la table products dont nous voulons n'afficher que productName et
--buyPrice sous les dénominations respectives de "Les articles" et "Les prix";
--lister les articles dont les prix sont compris entre 50 et 65. 

select productName as 'Les articles', buyPrice as 'Les prix'
from products
where buyPrice between 50 and 65


--6 Afficher la somme, que vous nommerez "Total [07/2004]", et qui est la somme de
--tous les paiements effectués dans la table payments depuis le 1 juillet 2004. 

select sum(amount) as 'Total [07/2004]' from payments
where paymentDate >='2004-07-01'


--7 Sélectionner dans les détails de commande (orderDetails), les commandes dont la
--quantité est supérieur ou égale à 50 que l'on veut grouper par numéro d'ordre. 

select orderNumber, quantityOrdered from orderdetails
where quantityOrdered >=50
group by orderNumber, quantityOrdered


--8 Sélectionner les clients (customerName) qui n'ont pas encore
--passé commande et trier par ordre alphabétique ascendant. 
select customers.customerNumber
from customers
inner join orders
on customers.customerNumber=orders.customerNumber
where [status] = 'cancelled'
order by customerName


--9. Combien d'employés (Nom, prenom, employeeNumber, jobTitle) ne sont
--rattachés à aucun bureau (officeCode) ?

select count (*) jobTitle from employees
where officeCode = NULL


--10. Combien y-a-t-il de villes différentes dans la table customers ?

select count(distinct city) from customers


--11. Quel est le nom et le numéro du client qui a payé le plus dans la table payments.On
--souhaite avoir la somme totale réellement payée pour chaque client dont on ne veut que
--le nom (pas le numéro).

SELECT TOP(1) customerName, SUM(amount) from customers
JOIN payments ON customers.customerNumber = payments.customerNumber
group by customerName
order by SUM(amount) DESC


--12. Dans la table des produits (products), nous voulons la quantité commandée, qui se
--trouve dans les détails des ordres (orderDetails), totale, et la somme des ventes,
--depuis le 01/01/2005, classés par ligne de produit (productLine).

select quantityOrdered from products
join orderdetails
on products.productCode=orderdetails.productCode
join orders
on orders.orderNumber=orderdetails.orderNumber
where orderDate > '2005-01-01'
order by productLine

--13. Afficher les identifiants, les dates et status des commandes, le nom du client ayant
--passé commande, ainsi que le nom, le code et la quantité d'articles commandé.


select orders.orderNumber, orders.orderDate, orders.[status], customers.contactFirstName,
customers.customerName, products.productName, products.productCode,
orderdetails.quantityOrdered from customers
join orders
on customers.customerNumber=orders.customerNumber
join orderdetails
on orders.orderNumber=orderdetails.orderNumber
join products
on orderdetails.productCode=products.productCode


--14. À partir des tables customers, employees, offices, orders, orderDetails, products
--afficher le nom du client, la ville et le pays du bureau, le prénom, le nom et
--le poste occupé par l'employé, les articles commandés, leur quantité, la ligne de produit
--et le prix d'achat.

select customerName as 'nom du client', offices.city as 'ville succursale',
offices.country as 'pays succursale', employees.firstName as 'prénom employé',
employees.lastName as 'nom employé', employees.jobTitle as 'poste occupé',
products.productName as 'articles commandés', products.quantityInStock as 'stock disponible',
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


--15. Créer un mécanisme qui se déclenche lors de l'enregistrement d'une commande
--permettant la mise à jour de la quantité en stock du (ou des) article(s)
--dans la table products.

create trigger RECCOM
on orderdetails
for insert
as begin update products set quantityInStock=quantityInStock - quantityOrdered
from products inner join inserted
on inserted.productCode=products.productCode
end


--16. Récupérer le dernier orderNumber. Donner le chiffre et la requête.
select top (1) orderNumber from orderdetails
order by orderNumber desc
--réponse: 10426


--17. Récupérer la quantité en stock pour l'article S10_1949 dans la table products.
--Donner le chiffre et la requête.
select quantityInStock from products
where productCode like 'S10_1949'
--réponse: 7275


--18. Insérer une nouvelle commande. Ecrire la requête
--L'ordre:
--Numéro d'ordre : le dernier orderNumber (cf. B) + 1
--Date de la commande : date du jour
--Date requise : date du jour + 7
--Date d'envoi : date du jour +5
--Status : In process
--Commentaire : Test du trigger
--Numéro client : 103 

insert into orders (orderNumber, orderDate, requiredDate, shippedDate,
[status], comments, customerNumber)
values ((select top (1) orderNumber from orderdetails
order by orderNumber desc)+1, getdate(), getdate()+7, getdate()+15, 'In process','Test du trigger', 103)


--19. Insérer un détail de commande. Ecrire la requête.
--Le détail de l'ordre
--Numéro d'ordre : le dernier orderNumber (cf. B) + 1
--Le code du produit : S10_1949
--Quantité commandée : 10
--Le prix pour chaque article : 55.25
--Numéro de ligne de la commande : 1

insert into orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
values ((select top (1) orderNumber from orderdetails
order by orderNumber desc), 'S10_1949', 10, 55.25, 1) 


--20 Créer une procédure stockée « affiche » prenant en paramètre un customerNumber
--et regroupant sous le nom du client (customerName) le prénom et le nom du contact
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

