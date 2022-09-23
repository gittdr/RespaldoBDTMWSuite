SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[auto_214_simple_sp]
@ord_number char(12)
as


declare @cmp_type char(3),
		@date datetime, 
		@e214_cmp_id char(8), 
		@ord_hdrnumber int, 
		@stp_number int,
		@appName NVARCHAR(128),
		@tmwUser VARCHAR(255)
		

--PTS74227 Get source of Status Data
	exec gettmwuser @tmwUser OUTPUT
	SELECT @appName = APP_NAME()

select @ord_hdrnumber = ord_hdrnumber from orderheader with(nolock) where ord_number = @ord_number


select stp_number, stp_sequence into #stops from stops with(nolock) where ord_hdrnumber = @ord_hdrnumber 


select @e214_cmp_id = ord_billto from orderheader with(nolock) where ord_number = @ord_number
select @date = getdate()

while exists (select * from #stops)
begin
	select @stp_number = min(stp_number) from #stops where stp_sequence = (select min(stp_sequence) from #stops)
	select @cmp_type = case stp_type 
		when 'PUP' then 'SH'
		when 'DRP' then 'CN'
		else 'XX'
		end
	from stops where stp_number = @stp_number

	exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'ARV','','',@date,0,'0,1,99',0,0,@appName,@tmwuser
	exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'DEP','','',@date,0,'0,1,99',0,0,@appName,@tmwuser
	exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'APPT','','',@date,0,'0,1,99',0,0,@appName,@tmwuser

	delete #stops where stp_number = @stp_number
end


GO
GRANT EXECUTE ON  [dbo].[auto_214_simple_sp] TO [public]
GO
