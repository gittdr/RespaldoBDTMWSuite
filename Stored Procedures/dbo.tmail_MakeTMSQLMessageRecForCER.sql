SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MakeTMSQLMessageRecForCER]
	@msg_From						VARCHAR(12),
	@msg_FromType					INT,
	@msg_To							VARCHAR(12),
	@msg_ToType						INT,
	@msg_FormID						INT,
	@msg_FilterData					VARCHAR(50),
	@msg_Subject					VARCHAR(50)

AS

-- =============================================================================
-- Stored Proc: [dbo].[tmail_MakeTMSQLMessageRecForCER]
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.09.04
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
--		001 - @msg_From						VARCHAR(12)
--		002 - @msg_FromType					INT
--		003 - @msg_To						VARCHAR(12)
--		004 - @msg_ToType					INT
--		005 - @msg_FormID					INT
--		006 - @msg_FilterData				VARCHAR(50)
--		007 - @msg_Subject					VARCHAR(50)
--		008 - @msg_FilterDataDupWaitSeconds	INT
--
--      Outputs:
--      ------------------------------------------------------------------------
--		001 - msg_id_return					INT
--
--	PARAMETERS:
--	001 - @msg_From						VARCHAR(12)
--	      This parameter indicates the asset id in which the message is being 
--		  assigned/sent from.
--	002 - @msg_FromType					INT
--	      This parameter indicates the assignment type (value list controlled 
--		  by TotalMail tblAddressTypes) 
--	003 - @msg_To						VARCHAR(12)
--	      This parameter indicates the asset id in which the message is being 
--		  assigned/sent to.
--	004 - @msg_ToType					INT
--	      This parameter indicates the assignment type (value list controlled 
--		  by TotalMail tblAddressTypes) 
--	005 - @msg_FormID					INT
--	      This parameter indicates the TotalMail Form to generate (if applicable)
--	006 - @msg_FilterData				VARCHAR(50)
--		  This is a special unique identifier for the message.  It is free 
--		  formed by the developer.  (ex. 'TEST:1')
--	007 - @msg_Subject					VARCHAR(50)
--	      This parameter indicates the subject of the message
--	008 - @msg_FilterDataDupWaitSeconds	INT
--	
--	001 - msg_id_return					INT
--	      This RETURN parameter indicates the identity of the header so that it
--		  can be used to insert the details
--  ===========================================================================
/*
Used for testing proc
EXEC tmail_MakeTMSQLMessageRecForCER
'ADMIN', 1, 'QUALCOMM', 4, 324, 'TEST:1', 'Testing proc'

*/
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
GRANT EXECUTE ON  [dbo].[tmail_MakeTMSQLMessageRecForCER] TO [public]
GO
