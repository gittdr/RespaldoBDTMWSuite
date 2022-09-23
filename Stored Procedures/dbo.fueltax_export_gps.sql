SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fueltax_export_gps] @startdate datetime,
					 @enddate datetime

AS

SELECT	CONVERT(char(10),ckc_tractor) ckc_tractor,
	CONVERT(char(8),ckc_date,112) ckc_dateddmmyy,
	CONVERT(char(2),ckc_date,8) + SUBSTRING(CONVERT(char(5),ckc_date,8),4,2) + SUBSTRING(CONVERT(char(8),ckc_date,8),7,2) ckc_dateddhhmm,
	CONVERT(char(7),ckc_latseconds) ckc_latseconds,
	CONVERT(char(7),ckc_longseconds) ckc_longseconds
INTO #t1
FROM checkcall
WHERE ckc_date >= @startdate AND ckc_date < DATEADD(dd,1,@enddate)
AND ckc_event = 'TRP' AND ckc_updatedby = 'TMAIL'

UPDATE #t1
SET ckc_latseconds = REPLICATE('0',7 - LEN(ckc_latseconds)) + ckc_latseconds,
    ckc_longseconds = REPLICATE('0',7 - LEN(ckc_longseconds)) + ckc_longseconds

SELECT	CONVERT(char(10),ckc_tractor) ckc_tractor,
	CONVERT(char(8),ckc_dateddmmyy) ckc_dateddmmyy,
	CONVERT(char(6),ckc_dateddhhmm) ckc_dateddhhmm,
	CONVERT(char(7),ckc_latseconds) ckc_latseconds,
	CONVERT(char(7),ckc_longseconds) ckc_longseconds
FROM #t1
ORDER BY ckc_dateddmmyy

GO
GRANT EXECUTE ON  [dbo].[fueltax_export_gps] TO [public]
GO
