select Sale_Date_Converted from PortfofolProject..nashvillagehousing
--standardize date format 
select SaleDate,convert(date,SaleDate) from PortfofolProject..nashvillagehousing
alter table	nashvillagehousing
add Sale_Date_Converted date;
update nashvillagehousing
Set Sale_Date_Converted = convert(date,SaleDate)
-- populate porverty address data
select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID,isnull(a.PropertyAddress,b.PropertyAddress) from PortfofolProject..nashvillagehousing a
join PortfofolProject..nashvillagehousing b on
a.ParcelID=b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)  
from PortfofolProject..nashvillagehousing a
join PortfofolProject..nashvillagehousing b
on
	a.ParcelID=b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--break out address into individual columns (addess, city,state)	
select  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address, 
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as city
from PortfofolProject..nashvillagehousing

alter table  PortfofolProject..nashvillagehousing
add Property_Split_Address nvarchar(255);
update PortfofolProject..nashvillagehousing
set Property_Split_Address =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfofolProject..nashvillagehousing
add Property_Split_City nvarchar(255);
update PortfofolProject..nashvillagehousing
set Property_Split_City =substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select Property_Split_Address,Property_Split_City from PortfofolProject..nashvillagehousing



--NOW I will split Owner address
select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfofolProject..nashvillagehousing

alter table  PortfofolProject..nashvillagehousing
add Owner_Split_Address nvarchar(255);
update PortfofolProject..nashvillagehousing
set Owner_Split_Address =parsename(replace(OwnerAddress,',','.'),3)

alter table PortfofolProject..nashvillagehousing
add Owner_Split_City nvarchar(255);
update PortfofolProject..nashvillagehousing
set Owner_Split_City =parsename(replace(OwnerAddress,',','.'),2)

alter table PortfofolProject..nashvillagehousing
add Owner_Split_State nvarchar(255);
update PortfofolProject..nashvillagehousing
set Owner_Split_State =parsename(replace(OwnerAddress,',','.'),1)
select * from PortfofolProject..nashvillagehousing

--- change Y and N to Yes and No in sold as Vacant
select distinct SoldAsVacant
from PortfofolProject..nashvillagehousing

select SoldAsVacant,
	case
		when SoldAsVacant= 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfofolProject..nashvillagehousing

update  PortfofolProject..nashvillagehousing
set SoldAsVacant = case
		when SoldAsVacant= 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfofolProject..nashvillagehousing

-- remove duplicate 
	with row_numb as (
	select *,row_number() over( 
	partition by ParcelId,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by UniqueId) row_num

	from PortfofolProject..nashvillagehousing
	)

	select * from row_numb
	where row_num >1
	order by ParcelId 
	-- now deleting this duplicates
	with row_numb as (
	select *,row_number() over( 
	partition by ParcelId,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				order by UniqueId) row_num

	from PortfofolProject..nashvillagehousing
	)

	delete from row_numb
	where row_num >1
-- delete unused columns


alter table PortfofolProject..nashvillagehousing
drop column OwnerAddress, TaxDistrict,PropertyAddress
-- i will delete saledate bc I have converted into date before
alter table PortfofolProject..nashvillagehousing
drop column SaleDate