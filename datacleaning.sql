SELECT *
FROM PortfolioProject..NasvilleHousing
ORDER BY ParcelID

-- Perubahan format tanggal

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NasvilleHousing

UPDATE PortfolioProject..NasvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NasvilleHousing
ADD SaleDateConverted Date

UPDATE NasvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Menghapus duplikat pada kolom PropertyAddress

SELECT *
FROM PortfolioProject..NasvilleHousing
ORDER BY ParcelID

SELECT db1.ParcelID, db1.PropertyAddress, db2.ParcelID, db2.PropertyAddress, ISNULL(db1.PropertyAddress, db2.PropertyAddress)
FROM PortfolioProject..NasvilleHousing db1
JOIN PortfolioProject..NasvilleHousing db2
	ON db1.ParcelID = db2.ParcelID
	AND db1.[UniqueID ] <> db2.[UniqueID ]
Where db1.PropertyAddress is NULL

UPDATE db1
SET PropertyAddress = ISNULL(db1.PropertyAddress, db2.PropertyAddress)
FROM PortfolioProject..NasvilleHousing db1
JOIN PortfolioProject..NasvilleHousing db2
	ON db1.ParcelID = db2.ParcelID
	AND db1.[UniqueID ] <> db2.[UniqueID ]
Where db1.PropertyAddress is NULL

-- Memecah kolom Address menjadi individual kolom (Address, City, State)

SELECT PropertyAddress
FROM NasvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
ADD PropertySplitAddress nvarchar(250)

UPDATE NasvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NasvilleHousing
ADD PropertySplitCity nvarchar(250)

UPDATE NasvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT SoldAsVacant
FROM NasvilleHousing

SELECT OwnerAddress
FROM NasvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
ADD OwnerSplitAddress nvarchar(250)

UPDATE NasvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NasvilleHousing
ADD OwnerSplitCity nvarchar(250)

UPDATE NasvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NasvilleHousing
ADD OwnerSplitState nvarchar(250)

UPDATE NasvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Mengubah Y dan N menjadi Yes dan No pada kolom Sold as Vacant

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NasvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NasvilleHousing

UPDATE NasvilleHousing
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Remove Duplicates

WITH RowNumCTE
AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
) row_num
FROM NasvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Menghapus kolom yang tidak terpakai

SELECT *
FROM NasvilleHousing

ALTER TABLE NasvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NasvilleHousing
DROP COLUMN SaleDate