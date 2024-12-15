/* Cleaning Data Projecct */

------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select *
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)
 
 
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousingData


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
	JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
	JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select *
From PortfolioProject.dbo.NashvilleHousingData
ORDER BY ParcelID


SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS PropertySplitAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddresS)) AS PropertySplitCity 
FROM NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress VARCHAR(255),
	PropertySplitCity VARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddresS))

	
Select *
From PortfolioProject.dbo.NashvilleHousingData
-----------------------

SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerSplitCity,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerSplitState
FROM NashvilleHousingData


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress VARCHAR(255),
	OwnerSplitCity VARCHAR(255),
	OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From PortfolioProject.dbo.NashvilleHousingData


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant


SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH DUPCTE AS (
	SELECT *,ROW_NUMBER() 
		OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) AS DUPROWS
	FROM PortfolioProject.dbo.NashvilleHousingData
)
SELECT *
--DELETE <> SELECT
FROM DUPCTE
WHERE DUPROWS > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress