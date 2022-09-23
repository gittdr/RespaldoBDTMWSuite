SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MakeTMSQLMessage_Rec]
	@msg_To							VARCHAR(12),
	@msg_ToType						INT,
	@msg_FormID						INT,
	@msg_FilterData					VARCHAR(50),
	@msg_Subject					VARCHAR(50)

AS

BEGIN

	DECLARE 
		@tmwuser						VARCHAR(100),
		@msg_254						VARCHAR(254),
		@msg_id							INT,
		@msg_seq						INT,
		@msg_FilterDataDupWaitSeconds	INT,
		@msg_From						VARCHAR(100),
		@msg_FromType					INT,
		@msg_id_return					INT

    ----------------------------------------------------------------------------
	-- Hard code user to Admin since this stored proc will be called by a service.
    SET @msg_From = 'Admin'
	----------------------------------------------------------------------------
    SET @msg_FilterDataDupWaitSeconds = 5
    SET @msg_FromType = 0
	----------------------------------------------------------------------------
	INSERT INTO [dbo].[TMSQLMessage] (
		msg_date, 
		msg_FormID, 
		msg_To, 
		msg_ToType, 
		msg_FilterData,
		msg_FilterDataDupWaitSeconds, 
		msg_From, 
		msg_FromType, 
		msg_Subject
		)
	VALUES (
		getdate(), 
		@msg_FormID, 
		@msg_To, 
		@msg_ToType,
		@msg_FilterData,
		@msg_FilterDataDupWaitSeconds, 
		@msg_From,
		@msg_FromType,
		@msg_Subject)
	 		
	SELECT @msg_id = @@IDENTITY
	
    SELECT @msg_id_return = @msg_id
    
    SELECT @msg_id_return AS 'msg_id_return'

END 

GO
GRANT EXECUTE ON  [dbo].[tmail_MakeTMSQLMessage_Rec] TO [public]
GO
