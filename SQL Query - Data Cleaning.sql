/*

Cleaning Data in SQL

*/

SELECT *
FROM PortfolioProject..Housing

-------------------------------------------------------------
-- CONVERT
-- Standardize data format
-- SaleDate has time in the end. I'll take that off
SELECT SaleDate
	, CONVERT(Date, SaleDate)
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
ADD SaleDateConverted Date;
UPDATE PortfolioProject..Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------------

-- Populate Property Address data - there are NULL values. 
-- It can be populated in the context of refrence point, so I'll look for refrence point
SELECT PropertyAddress
FROM PortfolioProject..Housing
WHERE PropertyAddress IS NULL

-- Looking for refrence point. It looks like ParcelID contains some usefull information about PropertyAddress.
SELECT *
FROM PortfolioProject..Housing
ORDER BY ParcelID

-- Here I compare refrence points toghether, where I can find that there are same ParcelIDs, but one of them doesn't has Property Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..Housing AS a
JOIN PortfolioProject..Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Final
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
	, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing AS a
JOIN PortfolioProject..Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- After update it shows no nulls, so it works
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing AS a
JOIN PortfolioProject..Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------
-- SUBSTRING, CHARINDEX, PARSENAME, REPLACE
-- Separate Addess column into individual columns - Address and City
SELECT PropertyAddress
FROM PortfolioProject..Housing

-- Getting rid of comma delimiter
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM PortfolioProject..Housing

-- Separate City
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..Housing

-- Adding two new columns to populate them with Address and City
ALTER TABLE PortfolioProject..Housing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject..Housing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE PortfolioProject..Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- OwnerAddress case - Separate (in easier way) PropertyAddress, City and State
SELECT OwnerAddress
FROM PortfolioProject..Housing

SELECT
PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..Housing

-- Adding columns
ALTER TABLE PortfolioProject..Housing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject..Housing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProject..Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..Housing
SET OwnerSplitAddress = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE PortfolioProject..Housing
SET OwnerSplitCity = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE PortfolioProject..Housing
SET OwnerSplitState = PARSENAME( REPLACE(OwnerAddress, ',', '.'), 1);

-------------------------------------------------------------
-- CASE statements
-- Changing Y and N to Yes and No in column SoldAsVacant
-- Checking how many Y, N, Yes and No are there
SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Amount
FROM 
	PortfolioProject..Housing
GROUP BY
	SoldAsVacant
ORDER BY
	Amount


SELECT 
	SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		   WHEN SoldAsVacant = 'N' THEN 'No'
		   ELSE SoldAsVacant
		   END
FROM 
	PortfolioProject..Housing

UPDATE PortfolioProject..Housing
SET
	SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------
