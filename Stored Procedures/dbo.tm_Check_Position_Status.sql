SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Check_Position_Status]	
						@sPositionSN varchar(12),
						@sCabUnitSN varchar(12),
						@sStatus varchar(12),
						@sFlags varchar(12)
AS
	DECLARE @iPositionSN int, 
			@iStatus int,
			@iFlags int,
			@iCabUnitSN int

	if ISNULL(@sStatus, '') = ''
		BEGIN
		RAISERROR ('tm_Check_Position_Status:Status must be passed in.', 16, 1)
		RETURN
		END

	if ISNULL(@sPositionSN, '') = '' AND ISNULL(@sCabUnitSN, '') = ''
		BEGIN
		RAISERROR ('tm_Check_Position_Status:Position SN or CabUnit SN must be passed in.', 16, 1)
		RETURN
		END
	
	SET @iPositionSN = CONVERT(int, @sPositionSN)
	SET @iCabUnitSN = CONVERT(int, @sCabUnitSN)
	SET @iStatus = CONVERT(int, @sStatus)
	SET @iFlags = CONVERT(int, @sFlags)

	if @iCabUnitSN > 0  --All Positions for unit
		BEGIN
			SELECT CASE WHEN EXISTS (SELECT NULL FROM tblLatLongs (NOLOCK) WHERE UNIT = @iCabUnitSN AND ((Status & @iStatus) > 0)) THEN 1 ELSE 0 END StatusEnabled 
		END
	else
		BEGIN
			SELECT CASE WHEN (Status & @iStatus > 0) THEN 1 ELSE 0 END StatusEnabled 
				FROM tblLatLongs (NOLOCK)
				WHERE SN = @iPositionSN
		END
GO
GRANT EXECUTE ON  [dbo].[tm_Check_Position_Status] TO [public]
GO
