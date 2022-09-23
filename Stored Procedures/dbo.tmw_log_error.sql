SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[tmw_log_error] @err_batch int, @err_message varchar(254), @err_number int, 
		@err_item_number varchar(20)
AS

-- Added this to use the SYSTEMS error messages when requested.
IF @err_message = 'SYSTEM' 
	SELECT @err_message = description FROM master.dbo.sysmessages WHERE error = @err_number

insert tts_errorlog (err_batch, err_user_id, err_message, err_date, err_number, err_title, err_item_number)
select @err_batch, 'SPOrderImp', @err_message, getdate(), @err_number, 'SP order import', @err_item_number
GO
GRANT EXECUTE ON  [dbo].[tmw_log_error] TO [public]
GO
