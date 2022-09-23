SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Set_Position_Status]	
						@sPositionSN varchar(12),
						@sStatus varchar(12),
						@sStatusReason varchar(255),
						@sFlags varchar(12)
AS

SET NOCOUNT ON 

	DECLARE @iPositionSN int, 
			@iStatus int,
			@iFlags int,
			@iUnit int

	if ISNULL(@sStatus, '') = ''
		BEGIN
		RAISERROR ('tm_Set_Position_Status:Status must be passed in.', 16, 1)
		RETURN
		END

	if ISNULL(@sPositionSN, '') = ''
		BEGIN
		RAISERROR ('tm_Set_Position_Status:Position SN must be passed in.', 16, 1)
		RETURN
		END
	
	SET @iPositionSN = CONVERT(int, @sPositionSN)
	SET @iStatus = CONVERT(int, @sStatus)
	SET @iFlags = CONVERT(int, @sFlags)

	IF (@iFlags = 0) OR (@iFlags & 1 > 0) --Add Status
		UPDATE tblLatLongs SET Status = ISNULL(STATUS, 0) | @iStatus, 
					StatusReason = CASE WHEN ISNULL(@sStatusReason, '') > '' THEN ISNULL(StatusReason,'') + ': ' + CHAR(13) + @sStatusReason ELSE StatusReason END
		WHERE SN = @sPositionSN	
	ELSE IF (@iFlags & 2 > 0)  --Remove Status
		UPDATE tblLatLongs SET 
					Status = CASE WHEN ISNULL(STATUS, 0) & @iStatus > 0 THEN ISNULL(STATUS, 0) ^ @iStatus ELSE ISNULL(STATUS, 0) END, 
					StatusReason = CASE WHEN ISNULL(@sStatusReason, '') > '' THEN StatusReason + ': ' + @sStatusReason ELSE StatusReason END
			WHERE SN = @sPositionSN			

SET NOCOUNT OFF
		
GO
GRANT EXECUTE ON  [dbo].[tm_Set_Position_Status] TO [public]
GO
