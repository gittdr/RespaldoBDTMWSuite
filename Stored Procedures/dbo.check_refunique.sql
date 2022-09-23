SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create proc [dbo].[check_refunique] 
@ord int,
@refnumber varchar(30),
@retval int output

as
declare	@typetoenforce varchar(60),
	@returnvalue int

select @typetoenforce = upper(gi_string1)
from generalinfo where gi_name = 'RefUnique'
If @typetoenforce is null or @typetoenforce = 'NONE'
	select retval = 0
else
begin
select @retval =  count(*) from referencenumber
where ref_type = @typetoenforce
and ref_number = @refnumber
and not (
	(ref_tablekey = @ord and ref_table='orderheader')
or
	(ref_tablekey in 
	(select stp_number from stops where ord_hdrnumber = @ord) and
	ref_table='stops')
or
	(ref_tablekey in
	(select fgt_number from freightdetail where stp_number in 
	(select stp_number from stops where ord_hdrnumber = @ord)) and
	ref_table='freightdetail')
)
end
            
GO
GRANT EXECUTE ON  [dbo].[check_refunique] TO [public]
GO
