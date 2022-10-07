SELECT *
FROM [tempdb].[dbo].[Nashville_Housing_Data]


--Populate Property Address Data
-- Parcel id and PropertyAddress have 1-1 releation

select * from dbo.Nashville_Housing_Data
---where PropertyAddress is Null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Nashville_Housing_Data a
join dbo.Nashville_Housing_Data b 
     on a.ParcelID= b.ParcelID
     and a.[UniqueID]<> b.UniqueID
WHERE a.PropertyAddress is Null 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Nashville_Housing_Data a
join dbo.Nashville_Housing_Data b 
     on a.ParcelID= b.ParcelID
     and a.[UniqueID]<> b.UniqueID
where a.PropertyAddress is NULL

--- Breaking out Address into Indiviual Columns (Address, City, State)

Select PropertyAddress 
from dbo.Nashville_Housing_Data 

select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
Substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
from dbo.Nashville_Housing_Data 

alter table dbo.Nashville_Housing_Data 
add PropertyAddressLane Nvarchar(255);

alter table dbo.Nashville_Housing_Data 
add PropertyCity Nvarchar(255);

Update dbo.Nashville_Housing_Data 
set PropertyAddressLane = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Update dbo.Nashville_Housing_Data 
set PropertyCity= Substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- OwnerAddress

select OwnerAddress
from dbo.Nashville_Housing_Data

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from dbo.Nashville_Housing_Data


alter table dbo.Nashville_Housing_Data 
add OwnerAddressLane Nvarchar(255), 
     OwnerAddressCity Nvarchar(255),
     OwnerAddressState Nvarchar(255);

Update dbo.Nashville_Housing_Data 
set OwnerAddressLane = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update dbo.Nashville_Housing_Data 
set OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update dbo.Nashville_Housing_Data 
set OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--- Change Y and N to Yes and No in SoldAsVacant

select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.Nashville_Housing_Data
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case WHEN SoldasVacant = 'Y' Then 'Yes'
     WHEN SoldasVacant = 'N' Then 'No'
     ELSE SoldasVacant 
     END
from dbo.Nashville_Housing_Data

UPDATE dbo.Nashville_Housing_Data
set SoldAsVacant = Case WHEN SoldasVacant = 'Y' Then 'Yes'
     WHEN SoldasVacant = 'N' Then 'No'
     ELSE SoldasVacant 
     END

-- Remove Duplicates

with RowNumCTE as(
select *,
 ROW_NUMBER() over (
     PARTITION BY ParcelID,
                  PropertyAddress,
                  SalePrice,
                  SaleDate,
                  LegalReference
                  ORDER BY UniqueId
 )row_num
 FROM DBO.Nashville_Housing_Data) 
 SELECT * FROM RowNumCTE

