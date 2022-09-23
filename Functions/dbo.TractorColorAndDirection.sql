SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TractorColorAndDirection]
(
@leg INT,
@nextstop INT,
@orderbillto VARCHAR(20),
@StopArrivalTime DATETIME, 
@ScheduledEarliest DATETIME,
@ScheduledLatest DATETIME,
@ETAArrivalTime DATETIME
)
RETURNs varchar (50)

AS

BEGIN
Declare @icon varchar (50)
Declare @ETACalcTime datetime
Declare @bufferminutes int
Declare @lastcheckcall varchar (20)
Declare @checkcall1 varchar(20)
Declare @secondtolastcheckcall varchar (20)
Declare @Checkcall2 varchar(20)
Declare @UseThisDate Datetime
declare @lastcheckcalldate datetime
declare @secondtolastcheckcalldate datetime
declare @ordbillto varchar (20)
declare @mov_number int

--SETUP CHECK CALL TABLE
DECLARE @CheckCallTable AS TABLE (ckc_number INT, ckc_lghnumber INT, ckc_date DATETIME ,  ckc_longseconds INT)
INSERT	INTO  @CheckCallTable (ckc_number, ckc_lghnumber, ckc_date, ckc_longseconds)
SELECT	ckc_number, ckc_lghnumber, ckc_date, ckc_longseconds
FROM	checkcall (NOLOCK)
WHERE	ckc_lghnumber = @leg

SELECT @lastcheckcalldate = MAX (ckc_date) FROM @CheckCallTable WHERE ckc_lghnumber = @leg
SELECT @lastcheckcall = MAX(ckc_number) FROM @CheckCallTable WHERE ckc_lghnumber = @leg and ckc_date = @lastcheckcalldate
SELECT @checkcall1 = ckc_longseconds FROM @CheckCallTable  WHERE ckc_number = @lastcheckcall
SELECT @secondtolastcheckcalldate = MAX (ckc_date) FROM @CheckCallTable WHERE ckc_lghnumber = @leg and ckc_date < @lastcheckcalldate and ckc_longseconds <> @checkcall1
SELECT @secondtolastcheckcall = MAX(ckc_number) FROM @CheckCallTable WHERE ckc_lghnumber = @leg 	and ckc_date = @secondtolastcheckcalldate	
SELECT @Checkcall2 = ckc_longseconds FROM @CheckCallTable WHERE ckc_number = @secondtolastcheckcall

SELECT @UseThisDate = ISNULL(@ETAArrivalTime, @StopArrivalTime)
SELECT @ordbillto = @orderbillto

IF @checkcall1 IS NOT NULL AND @Checkcall2 IS NOT NULL
	BEGIN
		If (@UseThisDate <= @ScheduledLatest AND @checkcall1 < @Checkcall2)
			BEGIN 
				RETURN 'TruckGreen'
			END 
			If 
			(@UseThisDate <= @ScheduledLatest AND @checkcall1 > @Checkcall2)
			BEGIN 
				RETURN 'TruckGreenWestBound' 
			END 
			If
			(@UseThisDate > DATEADD(MI,30, @ScheduledLatest) AND @checkcall1 < @Checkcall2)
			BEGIN
				RETURN 'TruckRedEastBound'
			END
			If
			(@UseThisDate > DATEADD(MI,30, @ScheduledLatest) AND @checkcall1 > @Checkcall2)
			BEGIN
				RETURN 'TruckRedWestBound'
			END
			If
			(@UseThisDate >= @ScheduledLatest and @UseThisDate <=DATEADD(MI,30,@ScheduledLatest) AND @checkcall1 < @Checkcall2)
			BEGIN 
				RETURN 'TruckYellowEastBound' 
			END
			If
			(@UseThisDate >= @ScheduledLatest and @UseThisDate <=DATEADD(MI,30,@ScheduledLatest) AND @checkcall1 > @Checkcall2)
			BEGIN 
				RETURN 'TruckYellowWestBound' 
			END
		RETURN 'TruckPink'
	END
ELSE
	BEGIN
		RETURN 'EastError' --orange arrow
	END
		RETURN 'WestError'
END
GO
