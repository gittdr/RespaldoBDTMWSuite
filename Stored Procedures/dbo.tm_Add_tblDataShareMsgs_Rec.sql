SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Add_tblDataShareMsgs_Rec]	
		@TrailerID				AS VARCHAR(8),
		@TractorID				AS VARCHAR(8),
		@RespFormID				AS VARCHAR(20),		-- AS INT
		@SCAC					AS VARCHAR(4),
		@DataSharing			AS CHAR,
		@Partner				AS VARCHAR(50),
		@DTSent					AS VARCHAR(25),		-- AS DATETIME,
		@DTRcvd					AS VARCHAR(25)		-- AS DATETIME,
AS

BEGIN

	DECLARE 
		@UpdatedOn AS DATETIME,
		@iRespFormID AS INT
	----------------------------------------------------------------------------
	-- Use the system time for the updatedon
	SELECT @UpdatedOn = GETDATE()
	----------------------------------------------------------------------------
	-- Validate the Form ID submitted on the inbound form.
	IF ISNUMERIC(@RespFormID) = 1 
		BEGIN
			SET @iRespFormID = CONVERT(INT,@RespFormID)
		END
	ELSE
		BEGIN
			SET @iRespFormID = 0
		END
	----------------------------------------------------------------------------
	INSERT INTO [dbo].[tblDataShareMsgs] (
		TrailerID,
		TractorID,
		RespFormID,
		SCAC,
		DataSharing,
		Partner,
		DTSent,
		DTRcvd,
		RqstSent,
		DTRqstSent,
		AckSent,
		DTAckSent,
		Updatedon
		)
	VALUES (
		@TrailerID,
		@TractorID,
		@RespFormID,
		@SCAC,
		@DataSharing,
		@Partner,
		CONVERT(DATETIME,@DTSent),
		CONVERT(DATETIME, @DTRcvd),
		'N',					-- Default value for new record
		'2049-12-31 23:59:59',	-- Default value for new record
		'N',					-- Default value for new record
		'2049-12-31 23:59:59',	-- Default value for new record
		@UpdatedOn 
		)
END	

GO
GRANT EXECUTE ON  [dbo].[tm_Add_tblDataShareMsgs_Rec] TO [public]
GO
