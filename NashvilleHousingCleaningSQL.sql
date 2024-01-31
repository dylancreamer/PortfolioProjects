/*

Cleaning Data in SQL Queries

*/

------------------------------------------------------------------------

-- Converting Sale Date


SELECT SaleDateconverted, CONVERT(Date,SaleDate)
FROM pproject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER Table NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM pproject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM pproject.dbo.NashvilleHousing a
JOIN pproject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  ISNULL(a.propertyaddress, b.PropertyAddress)
FROM pproject.dbo.NashvilleHousing a
JOIN pproject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM pproject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM pproject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER Table NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM pproject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM pproject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM pproject.dbo.NashvilleHousing


ALTER Table NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER Table NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER Table NashvilleHousing
ADD OwnerSplitState NVARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM pproject.dbo.NashvilleHousing

------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(soldasvacant), COUNT(SoldAsVacant)
FROM pproject.dbo.NashvilleHousing
GROUP BY Soldasvacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM pproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------------

-- Remove Duplicates with a CTE

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
					) as row_num

FROM pproject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1



------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PProject.dbo.NashvilleHousing

ALTER TABLE PProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, PopertySplitAddress, PopertySplitCity, SaleDate

