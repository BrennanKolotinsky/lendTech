# Let's first create all of the tables -- we are going to create a BOOKTYPE table, and a BOOKCOPY table to track individual copies of the book and the associated type

# this table will contain running totals of the each book AND will have a ONE-TO-MANY relationship with the book table
CREATE TABLE BookType (
    Id int AUTO_INCREMENT,
    Title varchar(255),
    Author varchar(255),
    Year date,

    # Extra columns to track inventory levels -- not required
    TotalCopies int, # this is a count of all of the copies of this type of book -- can run a query and count the total books in the Book table with this BookType id and count to determine this number OR you could autoincrement this everytime a new book is added with this bok types id
    CopiesAvailable int, # this is the number of copies available (ie. total copies - borrowed of this type); again you can query for this data or preferably automatically keep it in the table and change it on database updates
    CurrentRentals int DEFAULT 0, # how many copies are currently rented
    AllBorrowed boolean DEFAULT 0, # false (0) if not all copies are rented out, true if all copies are rented

    PRIMARY KEY (Id)
);

# this table will contain each individual book copy -- storing whether it is rented or not
CREATE TABLE BookCopy (
	Id int AUTO_INCREMENT,
	BookTypeId int NOT NULL, # book must belong to a book type
	BorrowerId int DEFAULT NULL, # book copy CAN be rented by a borrower

	# additional information worth tracking -- not required in assignment
	Borrowed boolean DEFAULT 0, # false (0) if copy isn't rented out, true if it is
	Condition varchar(255), # keeps information regarding damage -- that way if the copy is severly damaged after rental, charges can be applied

	PRIMARY KEY (Id),
    FOREIGN KEY (BookTypeId) REFERENCES BookType(Id), # allows for joins, showing information about this specific book (ex. the title)
    FOREIGN KEY (BorrowerId) REFERENCES Borrower(Id) # track who is renting this specific copy right now
);

# this table will track every time an order is placed to rent out one OR more books
CREATE TABLE Order (
	Id int AUTO_INCREMENT,
	RentalDate date NOT NULL,
	BorrowerId int NOT NULL, # this tracks who placed this order 

	# extra field
	numOfBooks int, # this is a total of the number of books -- could query for this information too
	
	PRIMARY KEY (Id),
	FOREIGN KEY (BorrowerId) REFERENCES Borrower(Id) # track who is renting this specific copy right now
);

# this table will track each and every book being rented in an order -- allowing for multiple books
CREATE TABLE BookRental (
	Id int AUTO_INCREMENT,
	OrderId int NOT NULL, # this is the order the book rental is attached to
	BookCopyId int NOT NULL, # this is the specific book copy this rental is attached to

	PRIMARY KEY (Id),
	FOREIGN KEY (OrderId) REFERENCES Order(Id),
	FOREIGN KEY (BookCopyId) REFERENCES BookCopy(Id)
);

# this table represents users who can borrow multiple books and can place multiple "orders"
CREATE TABLE Borrower (
    Id int AUTO_INCREMENT,
    FirstName varchar(255),
    LastName varchar(255),
    PrimaryPhoneNumber varchar(20), # This allows for storing international numbers with formatting
    AltPhoneNumber varchar(20)
    PRIMARY KEY (Id)
);

# table just to show a little bit extra work!
CREATE TABLE Address (
	Id int AUTO_INCREMENT,
    BorrowerId int NOT NULL, # addresses without a borrower id shouldn't be created
    
    StreetNumber int,
    StreetName varchar(255),
    PostalCode varchar(10), # can handle US zip codes
    Province char(2), # strictly two characters
    Country char(2), # example. CA or US
    City varchar(255),

    PRIMARY KEY (Id),
    FOREIGN KEY (BorrowerId) REFERENCES Borrower(Id)
);

# Let's start out by querying each book rental -- this will allow us to grab a total
SELECT B.Title as "Book Name", COUNT(*) as "# of books borrowed" FROM BookRental BR
INNER JOIN Order O ON O.Id = BR.OrderId # grab the order to get the date
INNER JOIN BookCopy BC ON BC.Id = BR.BookCopyId # we connect to the specific book copy rather than the type directly as that is how the database has been designed (this design allows us to connect the specific copy being rented to an order/user rather than just the type -- i.e. its better design for other challenges we would likely face like checking who damaged a copy)
INNER JOIN BookType BT ON BT.Id = BC.BookTypeId # get the book type to grab the title
WHERE O.RentalDate BETWEEN "2020-01-01" AND "2020-12-31" # select a date range in this format!
GROUP BY BT.id # group by the book type, so that we are counting the total of each type
ORDER BY COUNT(*) DESC; # descend so we get the highest results first
