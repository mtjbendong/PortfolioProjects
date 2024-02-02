SELECT *
FROM NashvilleHousing

--STANDARDIZED DATE FORMAT

-- ADDING THE SALEDATECONVERTED COLUMN
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

-- UPDATING/STANDARDIZED THE DATE IN SALEDATE COLUMN TO SALEDATEDCONVERTED COLUMN
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- CHECKING IF THE STANDARIZED VERSION OF SALEDATE COLUMN REFLECTS IN SALEDATECONVERTED COLUMN
SELECT
  SaleDateConverted,
  CONVERT(DATE, SaleDate)
FROM NashvilleHousing

-- POPULATE NULL PROPERTY ADDRESS

-- CHECKING PROPERTYADRESS CELLS WITH NULL VALUE
SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- FOUND OUT THAT SAME PARCEL ID HAD THE SAME PROPERTYADDRESS, WILL USE PARCELID TO POPULATE NULL PROPERTY ADDRESS
UPDATE a
SET
  PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
  PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
  PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- BREAKING PROPERTY ADDRESS INTO INDIVIDUAL COLUMN AS ADDRESS, CITY
-- USING SUBSTRING
SELECT
  SUBSTRING(
    PropertyAddress,
    1,
    CHARINDEX(',', PropertyAddress) -1
  ) AS Address,
  SUBSTRING(
    PropertyAddress,
    CHARINDEX(',', PropertyAddress) + 1,
    LEN(PropertyAddress)
  ) AS Address
FROM
  PortfolioProject.dbo.NashvilleHousing
  
-- ADDING NEW COLUMN FOR STREET ADDRESS
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- UPDATING COLUMN FOR STREET ADDRESS
UPDATE NashvilleHousing
SET
  PropertySplitAddress = SUBSTRING(
    PropertyAddress,
    1,
    CHARINDEX(',', PropertyAddress) -1
  )
  
-- ADDING COLUMN FOR CITY ADDRESS
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- UPDATING COLUMN FOR CITY ADDRESS
UPDATE NashvilleHousing
SET
  PropertySplitCity = SUBSTRING(
    PropertyAddress,
    CHARINDEX(',', PropertyAddress) + 1,
    LEN(PropertyAddress)
  )
  
 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- BREAKING OWNER ADDRESS INTO INDIVIDUAL COLUMN AS ADDRESS, CITY, STATE
-- USING PARSENAME
Select OwnerAddress
From
  PortfolioProject.dbo.NashvilleHousing
Select
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From
  PortfolioProject.dbo.NashvilleHousing
  
--ADDING COLUMNS FOR OWNER STREET, CITY AND STATE ADDRESS
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

-- UPDATING COLUMN FOR OWNER STREET, CITY AND STATE ADDRESS
Update NashvilleHousing
SET
  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
  
Update NashvilleHousing
SET
  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
  
Update NashvilleHousing
SET
  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  
Select *
From PortfolioProject.dbo.NashvilleHousing


--UPDATING SOLD AS VACANT COLUMN FROM Y OR N, TO YES OR NO
SELECT
  SoldAsVacant,
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
FROM
  PortfolioProject.dbo.NashvilleHousing
  
  
UPDATE NashvilleHousing
SET
  SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END



--REMOVING DUPLICATES


WITH RowNumCTE AS(
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY UniqueID
      ) row_num
    FROM
      PortfolioProject.dbo.NashvilleHousing
  )



-- SEEING DUPLICATE DATA, RUN WITH CTE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--  DELETE THE DUPLICATES RUN AGAIN THE QUERY ABOVE AND SEE THAT THERES NO LONGER DUPLICATES
-- SHOULD ALSO RUN THIS ONE WITH THE CTE
DELETE
FROM RowNumCTE
WHERE row_num > 1





-- DELETE UNUSED COLUMNS

SELECT *
FROM
  PortfolioProject.dbo.NashvilleHousing
  
ALTER TABLE
  PortfolioProject.dbo.NashvilleHousing DROP COLUMN OwnerAddress,
  TaxDistrict,
  PropertyAddress,
  SaleDate
