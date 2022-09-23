SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[SSRS_RB_BOL_01_REFS](@ord_hdrnumber int)  
as  

CREATE TABLE #temp_ref(
ref_number	varchar(60))

declare @ref_cnt int

Insert into #temp_ref
SELECT top 3 ref_type+':'+ref_number as ref_number
FROM referencenumber
WHERE ord_hdrnumber = @ord_hdrnumber
AND ref_table = 'orderheader'
ORDER BY ref_sequence

set @ref_cnt = (select count(*) from #temp_ref)

while @ref_cnt + 1 <= 3
Begin
	Insert into #temp_ref
	select ' ' as ref_number
	
	set @ref_cnt = @ref_cnt + 1
end

select * from #temp_ref

GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_BOL_01_REFS] TO [public]
GO
