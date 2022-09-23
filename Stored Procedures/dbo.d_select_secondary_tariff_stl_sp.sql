SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_select_secondary_tariff_stl_sp](  @tar_num int )

AS

Create table #temptbl (
	tar_number int,
	tar_desc varchar(50),
	tar_rate money, 
	cht_itemcode varchar(6),
	selected int
)

insert into #temptbl
  SELECT tariffkey.tar_number,   
         tariffheaderstl.tar_description,   
         tariffheaderstl.tar_rate tar_rate,
		tariffheaderstl.cht_itemcode,
		1
    FROM tariffaccessorialstl,   
         tariffkey,   
         tariffheaderstl  
   WHERE tariffaccessorialstl.trk_number = tariffkey.trk_number and  
         tariffkey.tar_number = tariffheaderstl.tar_number  and  
         tariffaccessorialstl.tar_number = @tar_num AND  
         tariffheaderstl.cht_rateunit = 'FLT' AND  
		tariffheaderstl.tar_rowbasis = 'NOT' AND	
		tariffheaderstl.tar_colbasis = 'NOT' AND
		tariffkey.trk_primary = 'N' 
ORDER BY tariffkey.tar_number ASC

--Get rate from pay type if 0 rate on tariff
update #temptbl
set tar_rate = coalesce(pyt_rate, 0)
from #temptbl
join paytype on paytype.pyt_itemcode = #temptbl.cht_itemcode
where tar_rate = 0

select tar_number, 
		tar_desc,
		tar_rate,
		selected
from #temptbl
where tar_rate <> 0

GO
GRANT EXECUTE ON  [dbo].[d_select_secondary_tariff_stl_sp] TO [public]
GO
