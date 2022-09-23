SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[SSRS_REV_BY_TRACTOR]
	(
	@StartDate DATETIME
	)

AS

--EXEC dbo.SSRS_REV_BY_TRACTOR '11/28/13'

DECLARE @WE1 DATETIME
		,@WE2 DATETIME
		,@WE3 DATETIME
		,@WE4 DATETIME
		,@WE5 DATETIME
		--,@StartDate DATETIME
		
--SELECT @StartDate = '11/25/13'

SET @WE1 = 
	CASE WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 1 THEN DATEADD(DAY,-1,CONVERT(VARCHAR,@StartDate,1))
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 2 THEN DATEADD(DAY,-2,CONVERT(VARCHAR,@StartDate,1))	
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 3 THEN DATEADD(DAY,-3,CONVERT(VARCHAR,@StartDate,1))	
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 4 THEN DATEADD(DAY,-4,CONVERT(VARCHAR,@StartDate,1))	
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 5 THEN DATEADD(DAY,-5,CONVERT(VARCHAR,@StartDate,1))	
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 6 THEN DATEADD(DAY,-6,CONVERT(VARCHAR,@StartDate,1))	
		 WHEN DATEPART(WEEKDAY,CONVERT(VARCHAR,@StartDate,1)) = 7 THEN CONVERT(VARCHAR,@StartDate,1)	
 
		 END

SELECT @WE2 = DATEADD(DAY,-7,@WE1)
	   ,@WE3 = DATEADD(DAY,-14,@WE1)
	   ,@WE4 = DATEADD(DAY,-21,@WE1)
	   ,@WE5 = DATEADD(DAY,-28,@WE1)
/*
SELECT @WE1 WE1
	   ,@WE2 WE2
	   ,@WE3 WE3
	   ,@WE4 WE4
	   ,@WE5 WE5
*/	   
CREATE TABLE #Results
	(
	Tractor VARCHAR(10)
	,CUR_Week VARCHAR(10)
	,CUR_Rev FLOAT
	,WE1_Date VARCHAR(10)
	,WE1_Rev FLOAT
	,WE2_Date VARCHAR(10)
	,WE2_Rev FLOAT
	,WE3_Date VARCHAR(10)
	,WE3_Rev FLOAT
	,WE4_Date VARCHAR(10)
	,WE4_Rev FLOAT
	)

INSERT INTO #Results
	(
	Tractor
	)
SELECT DISTINCT [Tractor ID]
FROM vSSRSRB_RevVsPay
WHERE [Order Ship Date] > @WE5
AND [Order Ship Date] < DATEADD(DAY,1,@StartDate)
AND [Tractor ID] <> 'UNKNOWN'
	
UPDATE r SET r.CUR_Week = SUBSTRING(CONVERT(VARCHAR,@StartDate,1),1,5)
			 ,r.WE1_Date = SUBSTRING(CONVERT(VARCHAR,@WE1,1),1,5)
			 ,r.WE2_Date = SUBSTRING(CONVERT(VARCHAR,@WE2,1),1,5)
			 ,r.WE3_Date = SUBSTRING(CONVERT(VARCHAR,@WE3,1),1,5)
			 ,r.WE4_Date = SUBSTRING(CONVERT(VARCHAR,@WE4,1),1,5)
FROM #Results r

--Get our cur week revenue
UPDATE r SET r.CUR_Rev = a.LineHaul
FROM 
	(
	SELECT [Tractor ID]
		   ,SUM([LineHaul Revenue]) LineHaul
	FROM VSSRSRB_RevVsPay
	WHERE [Order Ship Date] > @WE1
	AND [Order Ship Date] < DATEADD(DAY,1,@StartDate)
	GROUP BY [Tractor ID]
	) a 
JOIN #Results r
	ON a.[Tractor ID] = r.Tractor

--Get our week 1 revenue
UPDATE r SET r.WE1_Rev = a.LineHaul
FROM 
	(
	SELECT [Tractor ID]
		   ,SUM([LineHaul Revenue]) LineHaul
	FROM VSSRSRB_RevVsPay
	WHERE [Order Ship Date] > @WE2
	AND [Order Ship Date] < DATEADD(DAY,1,@WE1)
	GROUP BY [Tractor ID]
	) a 
JOIN #Results r
	ON a.[Tractor ID] = r.Tractor

--Get our week 2 revenue
UPDATE r SET r.WE2_Rev = a.LineHaul
FROM 
	(
	SELECT [Tractor ID]
		   ,SUM([LineHaul Revenue]) LineHaul
	FROM VSSRSRB_RevVsPay
	WHERE [Order Ship Date] > @WE3
	AND [Order Ship Date] < DATEADD(DAY,1,@WE2)
	GROUP BY [Tractor ID]
	) a 
JOIN #Results r
	ON a.[Tractor ID] = r.Tractor


--Get our week 3 revenue
UPDATE r SET r.WE3_Rev = a.LineHaul
FROM 
	(
	SELECT [Tractor ID]
		   ,SUM([LineHaul Revenue]) LineHaul
	FROM VSSRSRB_RevVsPay
	WHERE [Order Ship Date] > @WE4
	AND [Order Ship Date] < DATEADD(DAY,1,@WE3)
	GROUP BY [Tractor ID]
	) a 
JOIN #Results r
	ON a.[Tractor ID] = r.Tractor


--Get our week 4 revenue
UPDATE r SET r.WE4_Rev = a.LineHaul
FROM 
	(
	SELECT [Tractor ID]
		   ,SUM([LineHaul Revenue]) LineHaul
	FROM VSSRSRB_RevVsPay
	WHERE [Order Ship Date] > @WE5
	AND [Order Ship Date] < DATEADD(DAY,1,@WE4)
	GROUP BY [Tractor ID]
	) a 
JOIN #Results r
	ON a.[Tractor ID] = r.Tractor

SELECT * FROM #Results r

DROP TABLE #Results

GO
