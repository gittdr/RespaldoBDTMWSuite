SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttMakeTMSQLMessage_Rec]
	@msg_To							VARCHAR(13),
	@msg_ToType						INT,
	@msg_From						VARCHAR(13),
	@msg_FromType					INT,
	@msg_FormID						INT,
	@msg_FilterData					VARCHAR(50),
	@msg_Subject					VARCHAR(50)

AS

-- =============================================================================
-- Stored Proc: [dbo].[tmail_OttMakeTMSQLMessage_Rec]
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.05.12
-- Description:
--      This procedure will add a header record to the TMSQLMessage table.  This 
--		table is used as an entry point for making async TotalMail form messages.  
--		There may be accompanying TMSQLMessageData records when appropriate.
--		Those messages will use the @msg_id_return value created by this proc.
--
--		This proc was created from the asyncmessage_sp proc. 
--      
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @msg_To						VARCHAR(13)
--		002 - @msg_ToType					INT
--		003 - @msg_From						VARCHAR(13)
--		004 - @msg_FromType					INT
--		005 - @msg_FormID					INT
--		006 - @msg_FilterData				VARCHAR(50)
--		007 - @msg_Subject					VARCHAR(50)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		001 - msg_id_return					INT
--
-- =============================================================================
--	Input parameter descriptions:
--
--	001 - @msg_To						VARCHAR(13)
--	      This paramater indicates the asset id in which the message is being 
--		  assigned/sent to.
--	002 - @msg_ToType					INT
--	      This paramater indicates the assignment type (value list controled 
--		  by TotalMail tblAddressTypes) 
--	003 - @msg_To						VARCHAR(13)
--	      This paramater indicates the asset id in which the message is being 
--		  assigned/sent to.
--	004 - @msg_ToType					INT
--	      This paramater indicates the assignment type (value list controled 
--		  by TotalMail tblAddressTypes) 
--	005 - @msg_FormID					INT
--	      This paramater indicates the TotalMail Form to generate (if applicable)
--	006 - @msg_FilterData				VARCHAR(50)
--		  This is a special unique identifier for the message.  It is free 
--		  formed by the developer.  (ex. 'TEST:1')
--	007 - @msg_Subject					VARCHAR(50)
--	      This paramater indicates the subject of the message
-- =============================================================================
-- Modification Log:
-- PTS 77420 - VMS - 2014.05.12 - New
-- 
-- =============================================================================
-- Used for testing proc >>  EXEC tmail_OttMakeTMSQLMessage_Rec '', 0, '', 0, 0, '', ''
-- =============================================================================

BEGIN

	DECLARE 
		@tmwuser						VARCHAR(100),
		@msg_254						VARCHAR(254),
		@msg_id							INT,
		@msg_seq						INT,
		@msg_FilterDataDupWaitSeconds	INT,
		@msg_id_return					INT

    ----------------------------------------------------------------------------
    SET @msg_FilterDataDupWaitSeconds = 5
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
GRANT EXECUTE ON  [dbo].[tmail_OttMakeTMSQLMessage_Rec] TO [public]
GO
