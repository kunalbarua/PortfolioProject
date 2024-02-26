/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- (TASK 1) Standardize Date Format

--Creating a column named SaleDateConverted
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

--Converting the Date-Time format to Date-only format and populating SaleDateConverted column
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Displaying the updated SaleDateConverted column
Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing





 --------------------------------------------------------------------------------------------------------------------------

-- (TASK 2) Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID asc


--Observing the values of two tables to handle empty/null fields
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --UniqueID is distinct and this will get us different rows so that we can replace null data with the required data using ISNULL() function
Where a.PropertyAddress is null


--Updating the values empty/null fields
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) --Populating the null fields in table {a} with fields from table {b}
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- (TASK 3) Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address  --Separting the street address from the bigger data set
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City --Separting the city from the bigger data set

From PortfolioProject.dbo.NashvilleHousing

--Creating a column named PropertySplitAddress
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--Populating PropertySplitAddress column with required data
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


--Creating a column named PropertySplitCity
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--Populating PropertySplitCity column with required data
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------
--Another way of splitting strings and creating individual columns using a combination of PARSENAME() and REPLACE() function


Select *
From PortfolioProject.dbo.NashvilleHousing a

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS StreetAddress   --PARSENAME() only works where " . " is used as a delimiter, hence we replace " , " with " . " first
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
From PortfolioProject.dbo.NashvilleHousing


--Creating a column named OwnerSplitAddress
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

--Populating values for OwnerSplitAddress
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- (TASK 4) Replace Y and N with Yes and No in "Sold as Vacant" field

--Observing different values in SoldAsvacant column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2 --Here 2 represents Count(SoldAsVacant). SQL Server allows us to sort the result set based on ordianl positions of columns that appear in SELECT list



--Replacing Y with Yes and checking the values after
Select Distinct SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant --Do nothing
	   END AS UpdatedSoldAsVacant
From PortfolioProject.dbo.NashvilleHousing


--Updating the database with above changes
Update NashvilleHousing
SET SoldAsVacant 
= CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- (TASK 5) Remove Duplicates

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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- (TASK 6) Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
