SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_GetLastStopOnPreviousLeg] (@pStp as varchar(20), @pDrv as varchar(30), @pTrc as varchar(30), @pFlags as varchar(10))

AS

SET NOCOUNT ON 

DECLARE @iStop int
DECLARE @iLeg int
DECLARE @dAsgnDate datetime
DECLARE @iPreviousLeg int
DECLARE @iLastStop int
DECLARE @sAsgnType varchar(3)
DECLARE @sAsgnTypeSecondary varchar(3)
DECLARE @sAsgnID varchar(30)
DECLARE @sAsgnIDSecondary varchar(30)

--Validate the Stop
SET @iStop = -1

IF ISNUMERIC(@pstp) = 1
BEGIN
	SET @iStop = CONVERT(int,@pstp)
END
ELSE
BEGIN
	RAISERROR('Invalid Stop Number', 16, 1, @pstp)
	RETURN
END

IF NOT EXISTS (SELECT NULL 
				FROM stops (NOLOCK) 
				where stp_number = @iStop)
BEGIN
	RAISERROR('Invalid Stop Number', 16, 1, @pstp)
	RETURN
END

--Find the Leg for the Stop
SELECT @iLeg = ISNULL(lgh_number,-1) 
from stops (NOLOCK)
where stp_number = @iStop

--Initialize the Asset Assignment Type and ID
SET @sAsgnType = 'TRC'
SET @sAsgnID = @pTrc
SET @sAsgnTypeSecondary = ''
SET @sAsgnIDSecondary = ''

--Set the Assets based on Flags
IF @pFlags & 1 = 1 -- Use Drv
BEGIN
	SET @sAsgnType = 'DRV'
	SET @sAsgnTypeSecondary = ''
	SET @sAsgnID = @pDrv
	SET @sAsgnIDSecondary = ''
END

IF @pFlags & 2 = 2 -- Use Both Trc and Drv
BEGIN
	SET @sAsgnType = 'TRC'
	SET @sAsgnID = @pTrc
	SET @sAsgnTypeSecondary = 'DRV'
	SET @sAsgnIDSecondary = @pDrv
END

--Find the Assignment Date for the Stop Parameter
SELECT @dAsgnDate = asgn_date 
FROM assetassignment (NOLOCK)
WHERE asgn_type = @sAsgnType
	and asgn_id = @sAsgnID 
	and lgh_number = @iLeg
	and (@sAsgnTypeSecondary = ''
				OR
			lgh_number = (	SELECT lgh_number 
							FROM assetassignment (NOLOCK)
							WHERE asgn_type = @sAsgnTypeSecondary
			  					AND asgn_id = @sAsgnIDSecondary
								AND lgh_number = @iLeg
			 ))


--Find the Assignment Leg for the assignment preceding the Assignment Date from above
SELECT top 1 @iPreviousLeg =  lgh_number 
FROM assetassignment a (NOLOCK)
WHERE asgn_type = @sAsgnType
		and asgn_id = @sAsgnID 
		and asgn_date < @dAsgnDate
		and lgh_number <> @iLeg
		and (@sAsgnTypeSecondary = ''
				OR
			lgh_number IN (	SELECT lgh_number 
							FROM assetassignment
							WHERE asgn_type = @sAsgnTypeSecondary
			  					AND asgn_id = @sAsgnIDSecondary
								AND lgh_number = a.lgh_number
							
			 ))
ORDER BY asgn_date desc

--Find the Last Stop on the Leg identified above as the previous leg
SELECT @iLastStop = stp_number 
FROM stops (NOLOCK) 
WHERE lgh_number = @iPreviousLeg 
	and stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM STOPS (NOLOCK)WHERE lgh_number = @iPreviousLeg)

--Return Results
SELECT @iLastStop as StopNumber ,@iPreviousLeg as LegNumber

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLastStopOnPreviousLeg] TO [public]
GO
