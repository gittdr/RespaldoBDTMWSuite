SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  
CREATE PROC [dbo].[d_select_secondary_tariff_sp](  @tar_num int )

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
         tariffheader.tar_description,   
         tariffheader.tar_rate tar_rate,
		tariffheader.cht_itemcode,
		1
    FROM tariffaccessorial,   
         tariffkey,   
         tariffheader  
   WHERE tariffaccessorial.trk_number = tariffkey.trk_number and  
         tariffkey.tar_number = tariffheader.tar_number  and  
         tariffaccessorial.tar_number = @tar_num AND  
         tariffheader.cht_rateunit = 'FLT' AND  
		tariffheader.tar_rowbasis = 'NOT' AND	
		tariffheader.tar_colbasis = 'NOT' AND
		tariffkey.trk_primary = 'N' 
ORDER BY tariffkey.tar_number ASC

--Get rate from charge type if 0 rate on tariff
update #temptbl
set tar_rate = coalesce(cht_rate, 0)
from #temptbl
join chargetype on chargetype.cht_itemcode = #temptbl.cht_itemcode
where tar_rate = 0

select tar_number, 
		tar_desc,
		tar_rate,
		selected
from #temptbl
where tar_rate <> 0

GO
GRANT EXECUTE ON  [dbo].[d_select_secondary_tariff_sp] TO [public]
GO
