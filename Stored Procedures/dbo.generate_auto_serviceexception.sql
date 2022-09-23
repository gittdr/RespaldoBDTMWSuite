SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[generate_auto_serviceexception]
	@mov_number integer,
	@stp		integer,
	@cmp		varchar(8),
	@order		int,
	@description	varchar(255),
	@stpcty			int,
	@svc_id			int		OUTPUT
as

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


Declare @Terminal varchar(6)

/* Get the Tractor Terminal code		*/
select @Terminal = (select trc.trc_terminal from stops s join event e on s.stp_number = e.stp_number join tractorprofile trc on trc.trc_number = e.evt_tractor where s.stp_number = @stp )


select @svc_id = 0
select @svc_id = ISNULL(sxn_sequence_number,0) from serviceexception where sxn_stp_number = @stp and sxn_asgn_type = 'AUT' and sxn_delete_flag = 'N'
if @svc_id = 0 or @svc_id is null
	Begin
		INSERT INTO serviceexception ( sxn_stp_number, 
			sxn_asgn_type, 
			sxn_asgn_id, 
			sxn_expcode, 
			sxn_expdate, 
			sxn_mov_number, 
			sxn_createdby, 
			sxn_createddate, 
			sxn_affectspay, 
			sxn_ord_hdrnumber, 
			sxn_cmp_id, 
			sxn_cty_code, 
			sxn_delete_flag, 
			sxn_late, 
			sxn_contact_customer, 
			sxn_action_received,
			sxn_terminal ) 
		VALUES ( @stp, 
			'AUT', 
			@tmwuser, 
			'UNK', 
			'2049-12-31 23:59', 
			@mov_number, 
			@tmwuser, 
			getdate(),
			'N', 
			@order, 
			@cmp, 
			@stpcty, 
			'N', 
			'UNK', 
			'N', 
			'N',
			@Terminal )
			
		-- Get the ID created
		Select @svc_id = scope_Identity()
			
	End

Return @svc_id

GO
GRANT EXECUTE ON  [dbo].[generate_auto_serviceexception] TO [public]
GO
