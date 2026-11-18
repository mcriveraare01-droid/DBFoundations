--*************************************************************************--
-- Title: Assignment06
-- Author: MRivera
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 11-17-2026,MRivera,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MRivera')
	 Begin 
	  Alter Database [Assignment06DB_MRivera] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MRivera;
	 End
	Create Database Assignment06DB_MRivera;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MRivera;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Go
CREATE --drop
VIEW vCategories
AS
	SELECT
		CategoryID,
		CategoryName
	From dbo.Categories;
GO

Create --drop
VIEW vProducts with SCHEMABINDING
AS
	Select 
		productID,
		ProductName,
		CategoryID,
		UnitPrice
	From dbo.Products;
GO

Create --drop
VIEW vEmployees with SCHEMABINDING
AS
	SELECT
		EmployeeID,
		EmployeeFirstName,
		EmployeeLastName,
		ManagerID
	From dbo.Employees;
GO

Create --drop
View vInventories with SCHEMABINDING
AS
	Select 
		InventoryID,
		InventoryDate,
		EmployeeID,
		ProductId,
		COUNT
	from dbo.Inventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to public;
Go

Deny Select On Products to Public;
Grant Select On vProducts to public;
Go

Deny Select On Employees to Public;
Grant Select On vEmployees to public;
Go

Deny Select On Inventories to Public;
Grant Select On vInventories to public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
Select * From Categories;
go
Select * From Products;
go

Select
	CategoryName,
	ProductName, 
	UnitPrice
from Categories as C Join Products as P
on c.CategoryID= p.CategoryID
Order By CategoryName, ProductName;
GO
*/
--creating view 
Create --drop
View vProductsByCategories
AS 
	Select Top 10000000
	CategoryName,
	ProductName, 
	UnitPrice
	from dbo.Categories as C Join dbo.Products as P
	on c.CategoryID= p.CategoryID
	Order By CategoryName, ProductName;
GO
Select * From [dbo].[vProductsByCategories]

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/*
Select * From Products;
Select * From Inventories;

Select 
	ProductName,
	InventoryDate,
	COUNT
from Products as p Join Inventories as I
On p.ProductID= i.ProductID
Order By ProductName, InventoryDate, Count;
Go
*/
--creating view
go
Create --drop
View vInventoriesByProductsByDates
As 
	Select Top 100000
	ProductName,
	InventoryDate,
	COUNT
	From dbo.Products as p Join dbo.Inventories as i
	on p.ProductID = i.ProductID
	Order by ProductName, InventoryDate, Count;
Go
Select * From [dbo].[vInventoriesByProductsByDates]

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/*
Select * From Employees;--employeeId
go
Select * From Inventories;--employeeID 
go

Select Distinct
	InventoryDate,
	concat( EmployeeFirstName, ' ', EmployeeLastName) as [EmployeeName]
from Inventories as i join Employees as E
On i.EmployeeID= e.EmployeeID
order By InventoryDate;
*/
go
Create --drop 
View vInventoriesByEmployeesByDates
as
	Select Distinct top 100
		InventoryDate,
		Concat( EmployeeFirstname, ' ', EmployeeLastName) as [EmployeeName]
	from Inventories as i join employees as E
	On i.EmployeeID= e.EmployeeID
	order by InventoryDate;
Go

Select * From [dbo].[vInventoriesByEmployeesByDates]

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
--need categoryName, ProductName, InventoryDate, Count
--tables are categories, products, inventories
--connected by product.categoryID = category.Categoryid and inventories.productid = products.productID

Select 
	CategoryName,
	ProductName, 
	InventoryDate,
	COUNT
From Products as P
	Join Categories as c
		on p.CategoryID= c.CategoryID
	Join Inventories as I
		On p.ProductID= i.ProductID
Order By CategoryName, ProductName, InventoryDate, Count 
*/
GO
Create --drop
View vInventoriesByProductsByCategories
as 
	Select top 1000000
		CategoryName,
		ProductName, 
		InventoryDate,
		COUNT
	From dbo.Products as P
		Join dbo.Categories as c
			on p.CategoryID= c.CategoryID
		Join dbo.Inventories as I
			On p.ProductID= i.ProductID
	Order By CategoryName, ProductName, InventoryDate, Count;
	go 

Select * From [dbo].[vInventoriesByProductsByCategories]

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

GO
Create --drop
View vInventoriesByProductsByEmployees
as 
	Select top 1000000
		CategoryName,
		ProductName, 
		InventoryDate,
		COUNT,
		CONCAT(EmployeefirstName, ' ', EmployeeLastName) as [EmployeeName]
	From dbo.Products as P
		Join dbo.Categories as c
			on p.CategoryID= c.CategoryID
		Join dbo.Inventories as I
			On p.ProductID= i.ProductID
		Join dbo.Employees as E
			On i.EmployeeID= e.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
	go 

Select * From [dbo].[vInventoriesByProductsByEmployees]

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
/*
Select --subquery for productId
	ProductId
from Products
Where ProductName in ('Chai', 'chang')
*/
GO
--add to view
Create --drop
View vInventoriesForChaiAndChangByEmployees
as 
	Select top 1000000
		CategoryName,
		ProductName, 
		InventoryDate,
		COUNT,
		CONCAT(EmployeefirstName, ' ', EmployeeLastName) as [EmployeeName]
	From dbo.Products as P
		Join dbo.Categories as c
			on p.CategoryID= c.CategoryID
		Join dbo.Inventories as I
			On p.ProductID= i.ProductID
		Join dbo.Employees as E
			On i.EmployeeID= e.EmployeeID
	Where p.ProductID in ( Select ProductId
							from Products
							Where ProductName in ('Chai', 'chang')
						)
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
	go 

Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
Select 
	CONCAT(m.EmployeeFirstName, ' ', m.EmployeeLastName) as [Manager],
	CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) as [Employees]
from 
	Employees as e left join employees as m 
	on e.managerID= m.employeeID
order By Manager, Employees 
*/
GO
Create --drop
View vEmployeesByManager
AS
	Select top 100000
		Concat(m.EmployeeFirstName, ' ', m.EmployeeLastName) as [Manager],
		Concat(e.EmployeeFirstName, ' ', e.EmployeeLastName) as [Employee]
	From dbo.Employees as e Left Join dbo.Employees as M
		on e.ManagerID= m.EmployeeID
	Order By Manager, Employee;
Go

Select * From [dbo].[vEmployeesByManager]

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
Select 
	c.categoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	inventoryId,
	InventoryDate,
	Count,
	e.EmployeeID,
	Concat(e.EmployeeFirstName, ' ', e.EmployeeLastName) as [Employee],
	Concat(m.EmployeeFirstName, ' ', m.EmployeeLastName) as [Manager]
From 
	Categories as C
		join products as P
			on c.CategoryID= p.CategoryID
		join Inventories as I
			on p.ProductID= i.ProductID
		Join Employees as E
			on i.EmployeeID= e.EmployeeID
		JOIN employees as m 
			on e.ManagerID= m.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee;
GO
*/
go
create --drop
View vInventoriesByProductsByCategoriesByEmployees
AS 
Select top 100000000
	c.categoryID,
	CategoryName,
	p.ProductID,
	ProductName,
	UnitPrice,
	i.inventoryId,
	InventoryDate,
	Count,
	e.EmployeeID,
	Concat(e.EmployeeFirstName, ' ', e.EmployeeLastName) as [Employee],
	Concat(m.EmployeeFirstName, ' ', m.EmployeeLastName) as [Manager]
From 
	dbo.Categories as C
		join dbo.products as P
			on c.CategoryID= p.CategoryID
		join dbo.Inventories as I
			on p.ProductID= i.ProductID
		Join dbo.Employees as E
			on i.EmployeeID= e.EmployeeID
		JOIN dbo.employees as m 
			on e.ManagerID= m.EmployeeID
Order by CategoryName, ProductName, InventoryID, Employee;
GO

Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/