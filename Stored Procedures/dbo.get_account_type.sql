SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_account_type] (	@ass_id varchar(12), 
													@ass_type  varchar(6),
													@actg_type char(1) output)
as
/**
 * 
 * NAME:
 * dbo.get_account_type 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

if @ass_type = 'DRV'
	select @actg_type = mpp_actg_type
	from manpowerprofile 
	where mpp_id = @ass_id

else if @ass_type = 'TRC'
	select @actg_type = trc_actg_type
	from tractorprofile 
	where trc_number = @ass_id

else if @ass_type = 'TRL'
	select @actg_type = trl_actg_type
	from trailerprofile 
	where trl_number = @ass_id


if @actg_type IS null 
	select @actg_type = 'N'

return

GO
GRANT EXECUTE ON  [dbo].[get_account_type] TO [public]
GO
