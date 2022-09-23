SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_insertTrailerExp_sp] 
(	
	@trl_id varchar(13),
	@exp_expirationdate datetime
)
AS

declare 
	@user varchar(255)

set nocount on
	exec gettmwuser @user
	
	INSERT INTO expiration 
	(
		exp_code, exp_lastdate, exp_expirationdate,
		exp_routeto, exp_idtype, exp_id, 
		exp_completed, 
		exp_priority, exp_compldate, exp_creatdate, 
		exp_updateby, exp_updateon, exp_city 
	)
	VALUES 
	(
		'OUT', getdate(), @exp_expirationdate, 
		'UNKNOWN', 'TRL', @trl_id, 
		'N', 
		'1', '12-31-2049 23:59:0.000', getdate(), 
		@user, getdate(), 0 )
	
	--update trailer status
	exec trl_expstatus @trl_id
GO
GRANT EXECUTE ON  [dbo].[transf_insertTrailerExp_sp] TO [public]
GO
