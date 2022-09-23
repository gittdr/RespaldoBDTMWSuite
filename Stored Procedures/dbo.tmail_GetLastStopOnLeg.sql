SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_GetLastStopOnLeg] (@pLeg as varchar(20), @pFlags as varchar(10))

AS

	--Local Variables
	DECLARE @iLeg int
	DECLARE @iLastStop int
	DECLARE @ssid int
	DECLARE @NextLeg  int
	DECLARE @mpp_id varchar(50)

	--Temp Table
	CREATE TABLE #temploads (	sn int identity,
							lgh_number int,
							ordernum varchar(30)
						)

	--Parameter Validation
	IF ISNUMERIC(@pLeg) = 1
	BEGIN
		SET @iLeg = CONVERT(int,@pLeg)
	END
	ELSE
	BEGIN
		RAISERROR('INVALID LEG NUMBER', 16, 1, @pLeg)
		RETURN
	END

	IF NOT EXISTS (SELECT NULL FROM legheader (NOLOCK) where lgh_number = @iLeg)
	BEGIN
		RAISERROR('INVALID LEG NUMBER', 16, 1, @pLeg)
		RETURN
	END

	--Find the Last Stop on the Leg identified above as the previous leg
	SELECT @iLastStop = stp_number
	FROM stops 
	WHERE lgh_number = @iLeg 
		and stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM STOPS WHERE lgh_number = @iLeg )

	
	
	--Return Results
	SELECT @iLastStop as StopNumber 

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLastStopOnLeg] TO [public]
GO
