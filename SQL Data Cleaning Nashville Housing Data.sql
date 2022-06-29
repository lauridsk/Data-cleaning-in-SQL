/*

Cleaning Data in SQL

*/

----------------------------------------------------------------------------------------
-- Standardize date format to yyyy-mm-dd (e.g. from April 9, 2013 to 2013-04-09)  

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM housedata a
JOIN housedata b 
	ON a.parcelID = b.ParcelID

SELECT * FROM housedata

SELECT saledate FROM housedata 

SELECT str_to_date("April 9, 2013", "%M %d, %Y");

UPDATE housedata SET saledate = str_to_date(saledate, "%M %d, %Y");

SELECT saledate FROM housedata

----------------------------------------------------------------------------------------
-- Use "ParcelID" to populate missing property addresses
-- Check null and no null data in PropertyAddress viewed from the same ParcelID
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, 
IFNULL(a.propertyaddress, b.propertyaddress)
FROM housedata a
JOIN housedata b 
	ON a.parcelID = b.ParcelID 
	AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress IS NULL

-- Updating the PropertyAddress column by filling null values 
UPDATE housedata a
JOIN housedata b
	ON (a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID)
SET a.PropertyAddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------------------------------
-- Breaking out property address into individual columns (Address, City)

SELECT PropertyAddress FROM housedata

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) AS City
FROM housedata

ALTER TABLE housedata 
ADD PropertySplitAddress VARCHAR(255)

UPDATE housedata 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1)

ALTER TABLE housedata 
ADD PropertySplitCity VARCHAR(255)

UPDATE housedata 
SET PropertySplitCity = SUBSTRING(PropertyAddress, 
LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress))

SELECT Propertyaddress, propertysplitaddress, propertysplitcity FROM Housedata

----------------------------------------------------------------------------------------
-- Breaking out owner address into individual columns (Address, City, State)

SELECT owneraddress FROM housedata

SELECT
SUBSTRING_INDEX(owneraddress, ',', 1) AS part1,
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS part2,
SUBSTRING_INDEX(owneraddress, ',', -1) AS part3
FROM housedata

ALTER TABLE housedata
ADD OwnerSplitAddress varchar(255),
ADD OwnerSplitCity varchar(255),
ADD OwnerSplitState varchar (255)

UPDATE housedata 
SET
OwnerSplitAddress = SUBSTRING_INDEX(owneraddress, ',', 1),
OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1),
OwnerSplitState = SUBSTRING_INDEX(owneraddress, ',', -1)

SELECT ownersplitaddress, ownersplitcity, ownersplitstate FROM housedata

----------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold As Vacant" column

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM housedata
GROUP BY soldasvacant
ORDER BY 2

-- Change 'Y' and 'N' to 'Yes' and 'No'
SELECT soldasvacant
, CASE WHEN soldasvacant = 'Y' THEN 'Yes'
       WHEN soldasvacant = 'N' THEN 'No'
       ELSE soldasvacant
       END
FROM housedata

-- Updating new values
UPDATE housedata
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
       WHEN soldasvacant = 'N' THEN 'No'
       ELSE soldasvacant
       END
      
----------------------------------------------------------------------------------------
-- Remove Duplicates
-- Assign row_number for each unique row, if 1 it is a unique row, if 2 it is a duplicate
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 	UniqueID
				 	) row_num
FROM housedata

-- Find all rows that are duplicates (where row_num is 2)

SELECT 
	*
FROM 

(SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 	UniqueID) AS row_num
	FROM 
		housedata) t
WHERE
	row_num > 1;

-- Remove duplicates from table

DELETE FROM housedata 
WHERE UniqueID IN 
(SELECT UniqueID FROM (SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 	UniqueID) AS row_num
				 FROM housedata) t
WHERE row_num > 1);
----------------------------------------------------------------------------------------
-- Delete unused columns

SELECT * FROM housedata

ALTER TABLE housedata 
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress;
	
	
	
	
	
	
	
	
	
	
	









