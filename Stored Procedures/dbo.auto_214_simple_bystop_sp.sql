SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[auto_214_simple_bystop_sp]
@stp_number int
as

declare @cmp_type char(3), 
	@date datetime, 
	@e214_cmp_id char(8), 
	@ord_number varchar(12),
	@appName NVARCHAR(128),
	@tmwUser VARCHAR(255)
	
	--PTS74227 Get source of Status Data
	exec gettmwuser @tmwUser OUTPUT
	SELECT @appName = APP_NAME()

select @date = getdate(), 
	@cmp_type = case s.stp_type 
		when 'PUP' then 'SH'
		when 'DRP' then 'CN'
		else 'XX'
	end, 
	@e214_cmp_id = o.ord_billto, 
	@ord_number = o.ord_number 
	from stops s, orderheader o 
	where s.stp_number = @stp_number and o.ord_hdrnumber = s.ord_hdrnumber

exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'ARV','','',@date,0,'0,1,99',0,0,@appName,@tmwUser
exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'DEP','','',@date,0,'0,1,99',0,0,@appName,@tmwUser
exec auto_214_sp @ord_number, @e214_cmp_id, @cmp_type, '', @stp_number, 'APPT','','',@date,0,'0,1,99',0,0,@appName,@tmwUser

GO
GRANT EXECUTE ON  [dbo].[auto_214_simple_bystop_sp] TO [public]
GO
