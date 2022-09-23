SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[get_equipment_transit_status] 
(
@stopNum int
) 
as 
begin
DECLARE @ordNum int = (select ord_hdrnumber from stops where stp_number = @stopNum)
CREATE TABLE #statuses (status varchar(10))
insert into #statuses(status)
select stp_status from stops where ord_hdrnumber = @ordNum
if 'DNE' in (select status from #statuses)
begin
	if 'OPN' in (select status from #statuses)
		select 'IN TRANSIT'
	else
		select 'ARRIVED'
end
else
BEGIN
	select 'NOT LOADED'
END
drop table #statuses
end
GO
GRANT EXECUTE ON  [dbo].[get_equipment_transit_status] TO [public]
GO
