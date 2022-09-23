SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[tmw_log_error_sp](
@err_batch int,
@err_user_id varchar(20),
@err_message varchar(254),
@err_date datetime,
@err_number int,
@err_title varchar(254),
@err_response char(10),
@err_sequence int,
@err_icon char(1),
@err_item_number varchar(20),
@err_type varchar(6))
AS
/**
 * DESCRIPTION:
 * inserts a wor into the tts_errorlog table
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
@err_user_id,
@err_message,
@err_date,
@err_number,
@err_title,
@err_response,
@err_sequence,
@err_icon,
@err_item_number,
@err_type)

GO
GRANT EXECUTE ON  [dbo].[tmw_log_error_sp] TO [public]
GO
