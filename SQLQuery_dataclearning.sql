--Clearning data in given dataset
SELECT * 
FROM Porftolioproject..Sheet1$


--1.Standardize Date Format
Select Saledate, CONVERT(Date,SaleDate)
FROM Porftolioproject..Sheet1$

UPDATE Sheet1$
SET SaleDate=CONVERT(Date,SaleDate)

--Populate Property Address Data
Select *
FROM Porftolioproject..Sheet1$
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--2.SelfJoin queries & remomving NULLs
--if null for propertyaddress, replace with b.property address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Porftolioproject..Sheet1$ AS a
JOIN Porftolioproject..Sheet1$ AS b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a --*usealias
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Porftolioproject..Sheet1$ AS a
JOIN Porftolioproject..Sheet1$ AS b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]

--3 split address by delimeter, [Use substring()]
Select PropertyAddress
FROM Porftolioproject..Sheet1$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Porftolioproject..Sheet1$
-----------------------------------------------
ALTER TABLE Porftolioproject..Sheet1$
ADD Property_split_address NVARCHAR(255)

UPDATE Porftolioproject..Sheet1$
SET Property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE Porftolioproject..Sheet1$
ADD Property_split_by_city NVARCHAR(255)

UPDATE Porftolioproject..Sheet1$
SET Property_split_by_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Porftolioproject..Sheet1$

-------------
--4.Split owner address by delimeter [use PARSENAME]
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM Porftolioproject..Sheet1$
SELECT OwnerAddress 
FROM Porftolioproject..Sheet1$
ALTER TABLE Porftolioproject..Sheet1$
ADD Owner_split_address2 NVARCHAR(255)
UPDATE Porftolioproject..Sheet1$
SET Owner_split_address2 = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
ALTER TABLE Porftolioproject..Sheet1$
ADD Owner_split_city2 NVARCHAR(255)
UPDATE Porftolioproject..Sheet1$
SET Owner_split_city2 = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
ALTER TABLE Porftolioproject..Sheet1$
ADD Owner_split_state NVARCHAR(255)
UPDATE Porftolioproject..Sheet1$
SET Owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
SELECT *
FROM Porftolioproject..Sheet1$
------------
--5. Cleaning naming variations in column
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Porftolioproject..Sheet1$
GROUP BY SoldAsVacant
ORDER BY 2
SELECT SoldAsVacant, 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Porftolioproject..Sheet1$

UPDATE Sheet1$
SET SoldAsVacant=
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Porftolioproject..Sheet1$
-----------------------------------------------------
--Dedup (picking out dups from CTE >> delete)
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	ORDER BY UniqueID)
	row_num

FROM Porftolioproject..Sheet1$
)
SELECT *
FROM RowNumCTE
WHERE row_num >1 
ORDER BY PropertyAddress
--6. Remove unused columns
SELECT * FROM 
Porftolioproject..Sheet1$

ALTER TABLE Porftolioproject..Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Porftolioproject..Sheet1$
DROP COLUMN Saledate


