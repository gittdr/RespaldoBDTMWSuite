SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadTractorReport] (@tractor varchar(8), @BEGINTime datetime, @ENDTime datetime)

AS

SET NOCOUNT ON 

DECLARE
	@lghStartDateAndNum varchar(30),
	@lgh_number int

CREATE TABLE #stops ( 
	Seq int, 
	StopNum int,
	Company varchar(8), 
	ArrivedBy varchar(8),
	ArriveDiff int,
	DepartedBy varchar(8),
	DepartDiff int,
	ArvStatus varchar(4), 
	ArvTime datetime,
	DepStatus varchar(4),
	DepTime datetime,
	AadArvTime datetime, 
	AadArvConf int, 
	AadDepTime datetime, 
	AadDepConf int,
	ArvRadius decimal(7,2), 
	DepRadius decimal(7,2),
	Latitude decimal(12,4), 
	Longitude decimal(12,4),
	LastCkcTime datetime, 
	LastCkcDist decimal(12,4), 	
	LastCkcLat decimal(12,4), 	
	LastCkcLong decimal(12,4), 	
	LastCkcStatus int,
	LastStartCkcTime datetime, 
	LastStartCkcDist decimal(12,4), 	
	LastStartCkcLat decimal(12,4), 	
	LastStartCkcLong decimal(12,4), 	
	LastStartCkcStatus int,
	ArvCkcTime datetime, 
	ArvCkcDist decimal(12,4), 	
	ArvCkcLat decimal(12,4), 	
	ArvCkcLong decimal(12,4), 	
	ArvCkcStatus int,
	DepCkcTime datetime, 
	DepCkcDist decimal(12,4), 	
	DepCkcLat decimal(12,4), 	
	DepCkcLong decimal(12,4), 	
	DepCkcStatus int
	)

SELECT @lghStartDateAndNum = min(convert(char(19),lgh_startdate,20) + ' ' + convert(char(10),lgh_number)) 
FROM legheader (NOLOCK)
WHERE lgh_tractor = @tractor
		and lgh_startdate >= @BEGINTime
		and lgh_startdate < @ENDTime

SELECT @lghStartDateAndNum = isnull(@lghStartDateAndNum,'')

WHILE @lghStartDateAndNum <> ''
	BEGIN
	
		SELECT @lgh_number = convert(int,right(@lghStartDateAndNum,10))
	
		INSERT #stops EXEC dbo.tm_ckc_aadlghreport @lgh_number
	
		SELECT @lghStartDateAndNum = min(convert(char(19),lgh_startdate,20) + ' ' + convert(char(10),lgh_number)) 
		FROM legheader (NOLOCK) 
		WHERE lgh_tractor = @tractor
			and convert(char(19),lgh_startdate,20) + ' ' + convert(char(10),@lgh_number) > @lghStartDateAndNum
			and lgh_startdate < @ENDTime
	
	SELECT @lghStartDateAndNum = isnull(@lghStartDateAndNum,'')
	END

SELECT 
	left(convert(varchar,legheader.lgh_startdate,20),16) TripSegStart, 
	legheader.lgh_number TripSegNum, 
	legheader.mov_number MoveNum, 
	Seq, StopNum, Company, ArrivedBy, ArriveDiff, DepartedBy, DepartDiff, ArvStatus, 
	left(convert(varchar,ArvTime,20),16) ArvTime,
	DepStatus, 
	left(convert(varchar,DepTime,20),16) DepTime,
	left(convert(varchar,AadArvTime,20),16) AadArvTime,
	AadArvConf, 
	left(convert(varchar,AadDepTime,20),16) AadDepTime,
	AadDepConf, ArvRadius, DepRadius, Latitude, Longitude, 
	left(convert(varchar,LastCkcTime,20),16) LastCkcTime,
	LastCkcDist, LastCkcLat, LastCkcLong, LastCkcStatus, 
	left(convert(varchar,LastStartCkcTime,20),16) LastStartCkcTime,
	LastStartCkcDist, LastStartCkcLat, LastStartCkcLong, LastStartCkcStatus, 
	left(convert(varchar,ArvCkcTime,20),16) ArvCkcTime,
	ArvCkcDist, ArvCkcLat, ArvCkcLong, ArvCkcStatus, 
	left(convert(varchar,DepCkcTime,20),16) DepCkcTime,
	DepCkcDist, DepCkcLat, DepCkcLong, DepCkcStatus
FROM #stops
	join stops (NOLOCK)on stops.stp_number = #stops.StopNum
	join legheader (NOLOCK)on stops.lgh_number = legheader.lgh_number

DROP TABLE #stops
GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadTractorReport] TO [public]
GO
