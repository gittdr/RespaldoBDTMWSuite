SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[SSRS_RB_BOL_01_COMMODITY](@ord_hdrnumber int, @ord_consignee varchar(8))  
as  

CREATE TABLE #temp_commodity(
CmdCodeDesc	varchar(75),
fgt_count Decimal,
fgt_countunit varchar (6),
fgt_weight float,
fgt_weightunit varchar(6))


declare @cmd_cnt int

INSERT INTO #temp_commodity
SELECT fgt.cmd_code + ' - ' + cmd.cmd_name as CmdCodeDesc,
fgt_count,
fgt_countunit,
fgt_weight,
fgt_weightunit
FROM freightdetail fgt
	inner join commodity cmd ON cmd.cmd_code = fgt.cmd_code
WHERE fgt.stp_number = (select top 1 stp_number from stops where ord_hdrnumber = @ord_hdrnumber and cmp_id = @ord_consignee and stp_type = 'DRP'
					    order by stp_mfh_sequence desc) 
ORDER BY fgt.fgt_sequence

--set @cmd_cnt = (select count(*) from #temp_commodity)

--while @cmd_cnt + 1 <= 4
--Begin
--	Insert into #temp_commodity
--	select ' ' as CmdCodeDesc need more fields here weight unit count 
	
--	set @cmd_cnt = @cmd_cnt + 1
--end

select top 3
CmdCodeDesc	,
fgt_count ,
fgt_countunit ,
fgt_weight ,
fgt_weightunit 
from #temp_commodity


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_BOL_01_COMMODITY] TO [public]
GO
