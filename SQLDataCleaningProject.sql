/*
Cleaning Data in SQL Queries
*/


Select *
From dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--if a.PropertyAddres is null, we will populate it with address stored in b.PropertyAddress.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Updating the above changes to the table, (Updating using the alias a). So we now have no null property addresses left
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Splitting Address into Individual columns (Address,city,state)
Select PropertyAddress
From dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--Getting rid of the comma at the end of Address using CharIndex
-- Seperating City from the Address
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing 

--Using ParseName instead of substring for seperating values in owneraddress. Parsename operates in reverse values.
SELECT 
PARSENAME (REPLACE(OwnerAddress, ',' , '.'),3)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.'),2)
,PARSENAME (REPLACE(OwnerAddress, ',' , '.'),1)
FROM dbo.NashvilleHousing 





ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress =PARSENAME (REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' , '.'),1)


--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	   WHEN SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	   WHEN SoldAsVacant = 'N' THEN 'No' 
	   ELSE SoldAsVacant
	   END


--Removing Duplicates 

WITH RowNumCTE AS(
SELECT *,
        ROW_NUMBER() OVER(
	    PARTITION BY ParcelID,
							  PropertyAddress,
							  SalePrice,
							  SaleDate,
							  LegalReference
							  ORDER BY
									UniqueID
									) row_num
FROM dbo.NashvilleHousing
--order by ParcelID 
)
SELECT*
FROM RowNumCTE
WHERE row_num>1
ORDER by PropertyAddress
					  
SELECT* FROM dbo.NashvilleHousing

-- Delete Unused Columns



Select *
From dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
