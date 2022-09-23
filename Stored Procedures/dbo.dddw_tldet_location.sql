SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create  proc [dbo].[dddw_tldet_location]
@pup_or_drp varchar(3),
@ord_number varchar(12)
as

if @pup_or_drp = 'PUP'
begin
	if @ord_number > '0' 
		SELECT cmp_id, stp_schdtearliest as stp_arrivaldate, stp_schdtlatest as stp_departuredate
		from stops
		where (stp_type = 'PUP' or stp_event = 'CTR') and ord_hdrnumber = (select max(ord_hdrnumber) from orderheader where ord_number = @ord_number)
	else
		SELECT cmp_id, convert(datetime, '1/1/1900 00:00:00') as stp_arrivaldate, convert(datetime, '1/1/1900 00:00:00') as stp_departuredate
		from COMPANY
end
else
begin

	if @ord_number > '0'
		SELECT cmp_id, stp_schdtearliest as stp_arrivaldate, stp_schdtlatest as stp_departuredate
		from stops
		where stp_type = 'DRP' and ord_hdrnumber = (select max(ord_hdrnumber) from orderheader where ord_number = @ord_number)
	else
		SELECT cmp_id, convert(datetime, '1/1/1900 00:00:00') as stp_arrivaldate, convert(datetime, '1/1/1900 00:00:00') as stp_departuredate
		from COMPANY
end

GO
GRANT EXECUTE ON  [dbo].[dddw_tldet_location] TO [public]
GO
