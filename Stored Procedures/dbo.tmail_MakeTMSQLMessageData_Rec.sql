SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_MakeTMSQLMessageData_Rec]
	@msg_ID							INT,
	@msd_Seq						INT,
	@msd_FieldName					VARCHAR(30),
	@msd_FieldValue					VARCHAR(500)

AS

BEGIN

	INSERT INTO [dbo].[TMSQLMessageData] (
		msg_ID,
		msd_Seq,
		msd_FieldName,
		msd_FieldValue 
		)
	VALUES (
		@msg_ID , 
		@msd_Seq, 
		@msd_FieldName,
		@msd_FieldValue)
			
END 

GO
GRANT EXECUTE ON  [dbo].[tmail_MakeTMSQLMessageData_Rec] TO [public]
GO
