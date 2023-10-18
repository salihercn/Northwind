--1)Belirli bir kategori adýna göre ürünleri seçin.
Create Procedure dbo.GetCategoryProductName
     @categoryname nvarchar(15)
as
Begin
     Select c.CategoryName,p.ProductName from Categories c
	 join Products p on p.CategoryID = c.CategoryID
	 Where c.CategoryName = @categoryname;
End;
go
Exec dbo.GetCategoryProductName @categoryname = 'Condiments';

--2)Belirli bir ülkeye göre müþterileri seçin.
Create Proc dbo.GetCustomersCountry
     @countryname nvarchar(15)
as
Begin
     Select CustomerID,Country from Customers
	 Where @countryname = Country
End;
go
     Exec dbo.GetCustomersCountry @countryname = 'Germany';

--3)Belirli bir müþteri kimliðine göre sipariþleri seçin
Create Proc dbo.GetCustomerIDOrders
     @customerID nchar(5)
as
Begin
     Select CustomerID, OrderID from Orders
	 Where CustomerID = @customerID;
End;
go
     Exec dbo.GetCustomerIDOrders @customerID = 'VINET';

--4)Ürünler tablosundaki en yüksek fiyatlý ürünleri seçin.
Create Proc dbo.ProductMaxPrice
as
Begin
     Select * from Products
	 Where UnitPrice = (Select MAX(UnitPrice) from Products);
End;

--5)Belirli bir ürün adýna göre ürün bilgilerini seçin
Create Proc dbo.ProductNameInformation
     @productname nvarchar(40)
as
Begin
     Select * from Products
	 Where ProductName = @productname;
End;
go
     Exec dbo.ProductNameInformation @productname = 'Chai';

--6)Belirli bir tarih aralýðýna göre sipariþleri seçin
Create Proc dbo.DateTimeOrders
     @startdate datetime,
	 @enddate datetime
as
Begin
     Select * from Orders
	 Where OrderDate between @startdate and  @enddate
End;
go
    Exec dbo.DateTimeOrders '1996-07-04' , '1997-07-04';

--7)Belirli bir müþteri kimliðine göre toplam sipariþ tutarýný hesaplayýn
Create Proc dbo.TotalOrders
     @customerID nchar(5)
as
Begin
     Select o.CustomerID ,SUM(od.UnitPrice * od.Quantity) as TotalPrice from [Order Details] od
	 join Orders o on od.OrderID = o.OrderID
	 Where o.CustomerID = @customerID
	 Group by o.CustomerID 
End;
go
     Exec dbo.TotalOrders @customerID = 'BLONP'

--8)Belirli bir kategori adýna göre ürün sayýsýný hesaplayýn.
Create Proc dbo.GetCategoryProductTotal
     @categoryname nvarchar(15)
as
Begin
     Select c.CategoryName, COUNT(*) as ProductCount
	 from Categories c
	 join Products p on p.CategoryID = c.CategoryID
	 Where c.CategoryName = @categoryname
	 Group by c.CategoryName
End;
go
     Exec dbo.GetCategoryProductTotal  'Beverages'

	-- Orta Seviye
--9)Ürünlerin ortalama fiyatýný hesaplayýn.
Create Proc dbo.ProductAvgPrice

as
Begin
     Select AVG(UnitPrice) as Average
	 from Products 
	
End;
go 
     Exec dbo.ProductAvgPrice;

--10)Müþterilerin ortalama yaþýný hesaplayýn.
Create Proc dbo.EmployeeAvgAge

as
Begin
	 Select AVG(DATEDIFF(YEAR, BirthDate, GETDATE())) as Average
     from Employees;

End;
go 
     Exec dbo.EmployeeAvgAge;
	
--11)Sipariþlerin ortalama tutarýný hesaplayýn
Create Proc dbo.OrdersAvgrice
as
Begin
     Select od.OrderID ,AVG(od.UnitPrice * od.Quantity ) as AvgPrice
	 from [Order Details] od
	 Group by od.OrderID
	 Order by 2 desc;
End;
go
     Exec dbo.OrdersAvgrice;

--12)Ülkelere göre toplam sipariþ tutarýný hesaplayýn
Create Proc dbo.CountryOrderSum
as
Begin
     Select o.ShipCountry, Sum(od.UnitPrice * od.Quantity) as TotalPrice
	 from Orders o
	 join [Order Details] od on od.OrderID = o.OrderID
	 Group by o.ShipCountry;
End;

--13)Belirli bir ülkedeki müþterilerin ortalama sipariþ tutarýný hesaplayýn
Create Proc dbo.CountryOfCustomersOrder
     @countryname nvarchar(15)
as
Begin
     Select c.Country, AVG(od.Quantity * od.UnitPrice) as TotalPrice
	 from Customers c
	 join Orders o on o.CustomerID = c.CustomerID
	 join [Order Details] od on od.OrderID = o.OrderID
	 Where c.Country = @countryname
	 Group by c.Country;
End;
go
     Exec dbo.CountryOfCustomersOrder @countryname = 'USA';

--14)En fazla sipariþ yapan müþterileri seçin
Create Proc dbo.MostOrderCustomers
as
Begin
     Select Top 3 c.CustomerID, COUNT(o.OrderID) as OrderCount
	 from Customers c
	 join Orders o on o.CustomerID = c.CustomerID
	 Group by c.CustomerID
	 Order by 2 desc;
End;

--15)Her kategori için en çok satan ürünü seçin.
CREATE PROCEDURE dbo.GetBestSellingProductPerCategory
AS
BEGIN
    SELECT c.CategoryName, p.ProductName, od.TotalQuantity
    FROM (
        SELECT p.CategoryID, od.ProductID, SUM(od.Quantity) AS TotalQuantity,
               ROW_NUMBER() OVER (PARTITION BY p.CategoryID ORDER BY SUM(od.Quantity) DESC) AS rn
        FROM Products p
        INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
        GROUP BY p.CategoryID, od.ProductID
    ) AS od
    INNER JOIN Categories c ON c.CategoryID = od.CategoryID
    INNER JOIN Products p ON p.ProductID = od.ProductID
    WHERE od.rn = 1;
END;

--Ýleri Seviye
--16)Son 30 gün içinde sipariþ vermiþ olan tüm müþterileri iade eden bir saklý yordam oluþturun.
Create Proc dbo.ThirtyDaysOrders
as
Begin
  Declare @30Day Datetime = Dateadd(Day,-30,Getdate())

     Select c.CustomerID,o.OrderID from Customers c
	 join Orders o on o.CustomerID = c.CustomerID
	 Where o.OrderDate >= @30Day
	 Group by c.CustomerID, o.OrderID
End;
go
     Exec dbo.ThirtyDaysOrders;

--17)Geçen ay 10'dan fazla sipariþ edilen tüm ürünleri iade eden bir saklý yordam oluþturun.
Create Proc dbo.LastMonthOrders
as
Begin
   Declare @startdate Datetime = Dateadd(MONTH, -1, Getdate())
   Declare @enddate Datetime = Dateadd(DAY, -1, Dateadd(Month, 1, @startdate));
     
	 Select p.ProductID, p.ProductName, od.OrderID  from Products p
	   join [Order Details] od on od.ProductID = p.ProductID
	   join Orders o on o.OrderID = od.OrderID
		  Where o.OrderDate between @startdate and @enddate
	    Group by p.ProductID, p.ProductName, od.OrderID
     Having COUNT(o.OrderID)>10;
End;
go
    Exec dbo.LastMonthOrders;

--18)Geçen yýl 10.000 ABD dolarýndan fazla ürün satan tüm çalýþanlarý iade eden bir saklý yordam oluþturun.
Create dbo.LastlyYearSales
as
Begin
  Declare @startdate Datetime = Dateadd(YEAR, -1, Getdate())
  Declare @enddate Datetime = Dateadd(DAY, -1, Dateadd(Year, 1, @startdate));
   
   Select (e.FirstName + ' ' + e.LastName) as EmployeeName
   from Employees e
     join Orders o on o.EmployeeID = e.EmployeeID
	 join [Order Details] od on od.OrderID = o.OrderID
	 join Products p on p.ProductID = od.ProductID
   Where o.OrderDate between @startdate and @enddate
   Group by (e.FirstName + ' ' + e.LastName) 
   Having SUM(od.Quantity * p.UnitPrice)> 1000;
End;
go
   Exec dbo.LastlyYearSales;

--19) Kaliforniya'da yaþayan tüm müþteriler için sevkiyat adresini güncelleyen bir saklý yordam oluþturun.
Create Proc dbo.UpdateCustomersShipperAdress
as
Begin
     Update Customers 
	   set Address = '78 Sehelby St. Suite 17',
	       City = 'Adelanto',
		   PostalCode ='94118'
	
	Where Country = 'USA' and Region = 'CA';
End;
go
    Exec dbo.UpdateCustomersShipperAdress;

--20)Stoktaki tüm ürünlerin miktarýný %10 güncelleyen bir saklý yordam oluþturun.
Create Proc dbo.UnitsinStockUpdate
as
Begin
     Update Products
	 set UnitsInStock = UnitsInStock * 1.10;
End;
go 
     Exec dbo.UnitsinStockUpdate;

--21)Veritabanýna yeni bir müþteri ekleyen ve ayrýca müþteri iliþkileri yönetimi (CRM) sisteminde onlar için
--yeni bir hesap oluþturan bir saklý yordam oluþturun.
Create Table CRMAccounts
(
    CustomerID int,
    AccountName nvarchar(40),
    AccountType nvarchar(50),
    AccountStatus nvarchar(50)
)
go

Create Proc dbo.NewCustomerCRM
    @CompanyName nvarchar(40),
    @ContactName nvarchar(30),
    @Address nvarchar(60),
    @City nvarchar(15),
    @Country nvarchar(15),
    @AccountName nvarchar(40),
    @AccountType nvarchar(50),
    @AccountStatus nvarchar(50)
as
Begin
    
    Insert into Customers (CompanyName, ContactName, Address, City, Country)
    Values (@CompanyName, @ContactName, @Address, @City, @Country);

    Declare @CustomerID int = @@Identity;

    Insert into CRMAccounts (CustomerID, AccountName, AccountType, AccountStatus)
    Values (@CustomerID, @AccountName, @AccountType, @AccountStatus);
End;
go
   Exec dbo.NewCustomerCRM
    @CompanyName = 'ABC Company',
    @ContactName = 'John Smith',
    @Address = '123 Main St',
    @City = 'New York',
    @Country = 'USA',
    @AccountName = 'ABC Company Account',
    @AccountType = 'Corporate',
    @AccountStatus = 'Active';

--22)Veritabanýna yeni bir sipariþ ekleyen ve ayrýca müþteri için yeni bir fatura 
--oluþturan bir saklý yordam oluþturun.
Create Table Invoicess 
(
CustomerID int, 
OrderID int, 
InvoiceNumber int, 
InvoiceDate datetime, 
TotalAmount money
);
go
Create Proc dbo.NewOrderWithInvoice
    @CustomerID nchar(5),
    @EmployeeID int,
    @OrderDate datetime,
    @RequiredDate datetime,
    @ShippedDate datetime,
    @ShipVia int,
    @Freight money,
    @ShipName nvarchar(40),
    @ShipAddress nvarchar(60),
    @ShipCity nvarchar(15),
    @ShipRegion nvarchar(15),
    @ShipPostalCode nvarchar(10),
    @ShipCountry nvarchar(15),
    @InvoiceNumber nvarchar(50),
    @InvoiceDate datetime,
    @TotalAmount money
as
Begin
    
    Insert into Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia,
	Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
    Values (@CustomerID, @EmployeeID, @OrderDate, @RequiredDate, @ShippedDate, @ShipVia, @Freight, 
	@ShipName, @ShipAddress, @ShipCity, @ShipRegion, @ShipPostalCode, @ShipCountry);

    Declare @OrderID int = @@Identity;
r
    Insert into Invoices (CustomerID, OrderID, InvoiceNumber, InvoiceDate, TotalAmount)
    VALUES (@CustomerID, @OrderID, @InvoiceNumber, @InvoiceDate, @TotalAmount);
END;

--23)Veritabanýna yeni bir ürün ekleyen ve ayrýca tüm ambarlar için envanter düzeylerini güncelleyen
--bir saklý yordam oluþturun.
Create Proc dbo.GetProductWarehouse
    @ProductName nvarchar(40),
    @CategoryID int,
    @SupplierID int,
    @UnitPrice money,
    @UnitsInStock smallint,
    @ReorderLevel smallint
as
Begin

    Insert into Products (ProductName, CategoryID, SupplierID, UnitPrice, UnitsInStock, ReorderLevel)
    Values (@ProductName, @CategoryID, @SupplierID, @UnitPrice, @UnitsInStock, @ReorderLevel);

    Declare @ProductID int = @@Identity;

    Update Products
    SET UnitsInStock = UnitsInStock + @UnitsInStock
    WHERE ProductID = @ProductID;
END;
go
   
   Exec dbo.GetProductWarehouse
       @ProductName = 'Manga',
       @CategoryID = 1,
       @SupplierID = 1,
       @UnitPrice = 62.50,
       @UnitsInStock = 100,
       @ReorderLevel = 20;
	   
--24)Veritabanýna yeni bir çalýþan ekleyen ve ayrýca insan kaynaklarý (ÝK) sisteminde onlar için yeni bir 
--kullanýcý hesabýoluþturan bir saklý yordam oluþturun.
Create Table UserAccounts (
    EmployeeID int,
    Username nvarchar(50),
    Password nvarchar(50)
);
go
Create Proc dbo.NewEmployeeUser
   @LastName nvarchar(20), 
   @FirstName nvarchar(10), 
   @Title nvarchar(30), 
   @TitleOfCourtesy nvarchar(25), 
   @BirthDate datetime, 
   @HireDate datetime,
   @Address nvarchar(60), 
   @City nvarchar(15), 
   @Region nvarchar(15), 
   @PostalCode nvarchar(10), 
   @Country nvarchar(15), 
   @UserName nvarchar(50),
   @Password nvarchar(50)
as
Begin
     Insert into Employees (EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate,
	 Address, City, Region, PostalCode, Country)
	 Values ( @LastName, @FirstName, @Title, @TitleOfCourtesy, @BirthDate, @HireDate@Address,@City, 
              @Region, @PostalCode, @Country);

	    Declare @EmployeeID int = @@Identity
  
    Insert into UserAccounts (EmployeeID, Username, Password)
    VALUES (@EmployeeID, @UserName, @Password);
End;
go
EXEC dbo.NewEmployeeUser 'SLHERCN', 'Pitohui', '123456789';

--25)Bir müþteriyi veritabanýndan silen ve ayný zamanda CRM sistemindeki 
--hesabýný da silen bir saklý yordam oluþturun.
Create Proc dbo.DeleteCustomerWithCRM
    @CustomerID int
as
Begin

    Delete from Customers
    Where CustomerID = @CustomerID;

    DELETE FROM CRMAccounts
    WHERE CustomerID = @CustomerID;
END;
go
    Exec  dbo.DeleteCustomerWithCRM @CustomerID = 123;

--26)Bir sipariþi veritabanýndan silen ve ayný zamanda müþteri için faturayý da silen bir 
--saklý yordam oluþturun.
Create Proc dbo.DeleteOrderWithInvoices
    @OrderID int
as
Begin

    Delete from Orders
    Where OrderID = @OrderID;

    Delete Invoicess
    WHERE OrderID = @OrderID;
END;
go
    Exec  dbo.DeleteOrderWithInvoices @OrderID = 123;

--27)Bir ürünü veritabanýndan silen ve ayrýca tüm ambarlar için envanter düzeylerini güncelleyen 
--bir saklý yordam oluþturun.
Create Proc dbo.DeleteProductWithUpdate
    @ProductID int
as
Begin

    Delete from Products
    Where ProductID = @ProductID

    Update Products
	set UnitsInStock = 100
	Where ProductID = @ProductID
END;

--28)Bir çalýþaný veritabanýndan silen ve ayný zamanda ÝK sistemindeki kullanýcý hesabýný da silen
--bir saklý yordam oluþturun.
Create Proc dbo.DeleteEmployeeWithUser
    @EmployeeID int
as
Begin

    Delete from Employees
    Where EmployeeID = @EmployeeID

    Delete UserAccounts
    WHERE EmployeeID = @EmployeeID

END;

--29)Belirli bir müþteri için toplam satýþlarý alan ve ayný zamanda o müþteri tarafýndan verilen toplam 
--sipariþ sayýsýný da içeren bir saklý yordam oluþturun.
CREATE PROCEDURE dbo.GetCustomerSalesAndOrderCount
    @CustomerID INT
AS
BEGIN
    SELECT SUM(od.UnitPrice * od.Quantity) AS TotalSales, COUNT(o.OrderID) AS OrderCount
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE o.CustomerID = @CustomerID;
END;

--30)Belirli bir ürün için toplam satýþlarý alan ve ayný zamanda o ürünün satýlan toplam birim sayýsýný da
--içeren bir saklý yordam oluþturun.
Create Proc dbo.ProductSalesAndUnitCount
    @ProductID int
as
Begin
    Select SUM(od.UnitPrice * od.Quantity) as TotalSales, SUM(od.Quantity) as UnitCount
    from [Order Details] od
    Where od.ProductID = @ProductID;
End;

--31)Geçen yýl en çok para harcayan ilk 10 müþteriyi alan bir saklý yordam oluþturun.
Create Proc dbo.LastlyYearMoney
as
Begin
  Declare @startdate Datetime = Dateadd(YEAR, -1, Getdate())
  Declare @enddate Datetime = Dateadd(DAY, -1, Dateadd(Year, 1, @startdate));
     
	 Select Top 10 c.CustomerID, c.CompanyName, SUM(od.Quantity * od.UnitPrice) as Total
	 from Customers c
	   join Orders o on c.CustomerID  = o.CustomerID
	   join [Order Details] od on od.OrderID = o.OrderID
	 Where o.OrderDate between @startdate and @enddate
	 Group by  c.CustomerID,c.CompanyName
	 Order by Total desc;
End;
go
    Exec dbo.LastlyYearMoney;

--32)Geçen yýl en çok satýlan ilk 10 ürünü alan bir saklý yordam oluþturun.
Create Proc dbo.LastYearOrders
as
Begin
  Declare @startdate Datetime = Dateadd(YEAR, -1, Getdate())
  Declare @enddate Datetime = Dateadd(DAY, -1, Dateadd(Year, 1, @startdate));
     
	 Select Top 10 p.ProductName, COUNT(o.OrderID) as TotalSold
	 from Products p
	   join [Order Details] od on od.ProductID = p.ProductID
	   join Orders o on o.OrderID = od.OrderID
	 Where o.OrderDate between @startdate and @enddate
	 Group by  p.ProductName
	 Order by TotalSold desc;
End;
go 
     Exec dbo.LastYearOrders;

--33)Geçen yýl en çok ürünü satan ilk 10 çalýþaný alan bir saklý yordam oluþturun.
Create Proc dbo.LastYearEmployeeProdustSales
as
Begin
  Declare @startdate Datetime = Dateadd(YEAR, -1, Getdate())
  Declare @enddate Datetime = Dateadd(DAY, -1, Dateadd(Year, 1, @startdate));
     
	 Select Top 10 e.FirstName, e.LastName, COUNT(*) as TotalSold
	 from Employees e
	   join Orders o on o.EmployeeID = e.EmployeeID
	 Where o.OrderDate between @startdate and @enddate
	 Group by  e.FirstName, e.LastName
	 Order by TotalSold desc;
End;
go 
     Exec dbo.LastYearEmployeeProdustSales

--34)Son 30 gün içinde sipariþ vermiþ olan tüm müþterilerin raporunu oluþturan bir saklý yordam oluþturun.
Create Proc dbo.CustomesReport
as
Begin
    Declare @startdate DATETIME = DATEADD(DAY, -30, GETDATE());
    
    Select c.CustomerID, c.CompanyName, COUNT(*) AS TotalOrders
    from Customers c
    join Orders o on o.CustomerID = c.CustomerID
    WHERE o.OrderDate >= @StartDate
    GROUP BY c.CustomerID, c.CompanyName;
END;
go 
  exec dbo.CustomesReport;

--35) Geçen ay 10'dan fazla sipariþ edilen tüm ürünlerin raporunu oluþturan bir saklý yordam oluþturun.
Create Proc dbo.CustomesReport
as
Begin
    Declare @startdate DATETIME = DATEADD(MONTH, -30, GETDATE());
    Declare @enddate DATETIME = DATEADD(DAY, -30, Dateadd(Month, 1, @startdate));

    Select p.ProductID, p.ProductName, COUNT(*) AS TotalOrders
    from Products p
    join [Order Details] od on od.ProductID = p.ProductID
    join Orders o on o.OrderID = od.OrderID
    Where o.OrderDate between @startdate and @enddate
    GROUP BY p.ProductID, p.ProductName
    HAVING COUNT(*) > 10;
END;
go
   Exec dbo.CustomesReport;
