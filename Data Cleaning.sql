/*


Cleaning Data in SQL Queries


*/




SELECT *
FROM PortfolioProject..Nashville




-- 1. Standardize Date Format


SELECT SaleDate
FROM PortfolioProject..Nashville

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
ALTER COLUMN SaleDate DATE

--OR

UPDATE PortfolioProject..Nashville
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE PortfolioProject..Nashville
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..Nashville
SET SaleDateConverted = CONVERT(DATE, SaleDate)




-- 2. Populate Property Address Data


SELECT PropertyAddress
FROM PortfolioProject..Nashville
WHERE PropertyAddress IS NULL


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..Nashville A
JOIN PortfolioProject..Nashville B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..Nashville A
JOIN PortfolioProject..Nashville B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL




--3. Breaking Out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..Nashville
WHERE PropertyAddress IS NULL

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..Nashville


ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..Nashville
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject..Nashville
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..Nashville
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject..Nashville

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..Nashville


ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE PortfolioProject..Nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)




--4. Changing Y and N to 'Yes' and 'No' in "SoldAsVacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..Nashville

UPDATE PortfolioProject..Nashville
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



--5. Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
						) Row_Num
FROM PortfolioProject..Nashville
)
SELECT *
FROM RowNumCTE
WHERE Row_Num >1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
						) Row_Num
FROM PortfolioProject..Nashville
)
DELETE
FROM RowNumCTE
WHERE Row_Num >1




-- 6. Delete Unused Columns

SELECT *
FROM PortfolioProject..Nashville


ALTER TABLE PortfolioProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress