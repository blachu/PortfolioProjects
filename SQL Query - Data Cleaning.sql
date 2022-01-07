/*

Cleaning Data in SQL

*/

SELECT *
FROM PortfolioProject..Housing

-------------------------------------------------------------

-- Standardize data format
-- SaleDate has time in the end. I'll take that off
SELECT SaleDate
	, CONVERT(Date, SaleDate)
FROM PortfolioProject..Housing

ALTER TABLE Housing
ADD SaleDateConverted Date;
UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..Housing

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
