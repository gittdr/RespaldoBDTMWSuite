SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[tmw_log_error_short_sp](
@err_batch int,
@err_message varchar(254),
@err_sequence int,
@err_item_number varchar(20))
AS
/**
 * DESCRIPTION:
 * inserts a row into the tts_errorlog table
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 03/10/2008.01 ? vjh ? original creation
 *
 **/
declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

insert tts_errorlog
(err_batch,
err_user_id,
err_message,
err_date,
err_number,
err_title,
err_response,
err_sequence,
err_icon,
err_item_number,
err_type)
values
(
@err_batch,
left(@tmwuser,20),
@err_message,
getdate(),
null,
null,
null,
@err_sequence,
null,
@err_item_number,
null)

GO
GRANT EXECUTE ON  [dbo].[tmw_log_error_short_sp] TO [public]
GO
