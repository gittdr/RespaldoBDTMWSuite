SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_inbound_insertForeignTrailer_sp] 
(	
	@trl_number varchar(8),
	@trl_ilt_scac varchar(4)
)
AS

declare 
	@user varchar(255)

set nocount on
	exec gettmwuser @user
	if @user is null
		set @user = user_name()
	
	INSERT INTO trailerprofile 
	( 
		trl_number, 
		trl_make, trl_model, 
		trl_status, 
		trl_updatedby,
		trl_startdate,
		trl_retiredate, 
		trl_sch_cmp_id, 
		trl_sch_status, 
		trl_fix_record, 
		trl_last_stop, 
		trl_id,
		trl_cur_mileage,
		trl_avail_date,trl_updateon, trl_createdate,
		trl_quickentry, 
		trl_ilt_scac,
		trl_branch
	) 
	VALUES 
	(
		@trl_number,
		'UNK', 'UNK',
		'AVL',
		@user,
		'1/1/1950 00:00:00',
		'12/31/2049 23:59:59',
		'UNKNOWN',
		'AVL',
		'N',
		0,
		@trl_ilt_scac + ',' + @trl_number,
		0,
		getdate(), getdate(), getdate(),
		'Y',
		@trl_ilt_scac,
		'UNKNOWN'
	)

GO
GRANT EXECUTE ON  [dbo].[edi_inbound_insertForeignTrailer_sp] TO [public]
GO
