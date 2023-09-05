--SQL query fo Data Cleaning

SELECT *
FROM SQLPortfolioProject.dbo.[Nashville Housing]
order by ParcelID

--Standarize the date format

--UPDATE [Nashville Housing]
--SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD UpdatedSaleDate Date;

UPDATE [Nashville Housing]
SET UpdatedSaleDate=CONVERT(Date,SaleDate)

-------------------------------------------------------------
--populate property address :property address has null value so
--we go to populate with the parcel id with same address

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolioProject.dbo.[Nashville Housing] a
JOIN SQLPortfolioProject.dbo.[Nashville Housing] b
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolioProject.dbo.[Nashville Housing] a
JOIN SQLPortfolioProject.dbo.[Nashville Housing] b
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------
--Breaking out address(address,city,state)

--SELECT PropertyAddress
--FROM SQLPortfolioProject.dbo.[Nashville Housing]
SELECT 
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )AS City
FROM SQLPortfolioProject.dbo.[Nashville Housing]

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD SplitedAddress nvarchar(255);
UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET SplitedAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD City nvarchar(255);
UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )

SELECT OwnerAddress
FROM SQLPortfolioProject.dbo.[Nashville Housing]

5548  MURPHYWOOD XING, ANTIOCH, TN
107  DEMOSS RD, NASHVILLE, TN

SELECT 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS SplitOwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM SQLPortfolioProject.dbo.[Nashville Housing]

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD SplitOwnerAddress nvarchar(255);

UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET SplitOwnerAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD OwnersCity nvarchar(255);

UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET OwnersCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD OwnersStates nvarchar(255);

UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET  OwnersStates=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------
--change the Y and N to Yes and No in soldAsVacant
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM SQLPortfolioProject.dbo.[Nashville Housing]

ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
ADD SoldVacant nvarchar(255);

UPDATE SQLPortfolioProject.dbo.[Nashville Housing]
SET SoldVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM SQLPortfolioProject.dbo.[Nashville Housing]
-----------------------------------------------------
--Remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQLPortfolioProject.dbo.[Nashville Housing]
)
DELETE
From RowNumCTE
Where row_num > 1
------------------------------------------------
--Deleting the column
ALTER TABLE SQLPortfolioProject.dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

