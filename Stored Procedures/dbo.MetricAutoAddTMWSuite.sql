SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAutoAddTMWSuite]
AS
	DECLARE @MaxSortForCategoryItem int

	CREATE TABLE #TempMetrics (
		[sn] [int] IDENTITY(1,1) NOT NULL,
		[MetricCode] [varchar](200) NOT NULL,
		[Active] [int] NOT NULL DEFAULT ((1)),
		[Sort] [int] NOT NULL DEFAULT ((1)),
		[FormatText] [varchar](12) NOT NULL DEFAULT (''),
		[NumDigitsAfterDecimal] [int] NOT NULL DEFAULT ((0)),
		[PlusDeltaIsGood] [int] NOT NULL DEFAULT ((1)),
		[Cumulative] [int] NOT NULL DEFAULT ((0)),
		[Caption] [varchar](80) NULL,
		[CaptionFull] [varchar](255) NULL,
		[ProcedureName] [varchar](50) NULL,
		[RefreshHistoryYN] [varchar](1) NULL
	)
	-- add mapping metrics
	INSERT INTO #TempMetrics (MetricCode, Active, Sort, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, Caption, CaptionFull, ProcedureName, RefreshHistoryYN)
	SELECT MetricCode = CASE WHEN NOT EXISTS(SELECT sn FROM metricitem WHERE metriccode = 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5)) 
							THEN 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5)
							ELSE 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5) + REPLACE(LEFT(CONVERT(varchar(36), newid()), 13), '-', '')
						END,
			Active = 0,
			Sort = 9999,
			FormatText = '',
			NumDigitsAfterDecimal = 0, 
			PlusDeltaIsGood = 1,
			Cumulative = 0,
			Caption = 'Added ' + CASE WHEN NOT EXISTS(SELECT sn FROM metricitem WHERE metriccode = RIGHT(t1.name, LEN(t1.name) - 7) ) 
							THEN 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5)
							ELSE 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5) + REPLACE(LEFT(CONVERT(varchar(36), newid()), 13), '-', '')
						END,
			CaptionFull = 'Added ' + CASE WHEN NOT EXISTS(SELECT sn FROM metricitem WHERE metriccode = RIGHT(t1.name, LEN(t1.name) - 7) ) 
							THEN 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5)
							ELSE 'MSMap_' + RIGHT(t1.name, LEN(t1.name) - 5) + REPLACE(LEFT(CONVERT(varchar(36), newid()), 13), '-', '')
						END,
			ProcedureName = name,
			RefreshHistoryYN = ''
		FROM sysobjects t1 WHERE t1.type = 'p' AND t1.name like 'MapQ%' AND substring(t1.name,5,1) = '_' AND Not t1.name like '%Update'
			AND NOT EXISTS(SELECT sn FROM metricitem WHERE procedurename = t1.name)
		ORDER BY CASE WHEN NOT EXISTS(SELECT sn FROM metricitem WHERE metriccode = RIGHT(t1.name, LEN(t1.name) - 7) ) 
							THEN RIGHT(t1.name, LEN(t1.name) - 7)
							ELSE RIGHT(t1.name, LEN(t1.name) - 7) + REPLACE(LEFT(CONVERT(varchar(36), newid()), 13), '-', '')
						END

	DELETE #TempMetrics WHERE EXISTS(SELECT sn FROM metricitem WHERE metriccode = #TempMetrics.metriccode)

	INSERT INTO MetricItem (MetricCode, Active, Sort, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, Caption, CaptionFull, ProcedureName, RefreshHistoryYN)
	SELECT MetricCode, Active, Sort, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, Caption, CaptionFull, ProcedureName, RefreshHistoryYN 
	FROM #TempMetrics 

	IF NOT EXISTS(SELECT * FROM metriccategory WHERE CategoryCode = 'ZZ_AutoAddedByTMW')
		INSERT INTO MetricCategory (CategoryCode, Active, Sort, ShowTime, Caption, CaptionFull)
		SELECT 'ZZ_AutoAddedByTMW', 1, 99999, 0, 'ZZ_AutoAddedByTMW', 'ZZ_AutoAddedByTMW'

	SELECT @MaxSortForCategoryItem = ISNULL((SELECT MAX(sort) FROM MetricCategoryItems WHERE CategoryCode = 'ZZ_AutoAddedByTMW' AND sort IS NOT NULL), 0)

	IF NOT EXISTS(SELECT * FROM metriccategory t1 INNER JOIN metriccategoryitems t2 ON t1.categorycode = t2.categorycode 
					WHERE t1.CategoryCode = 'ZZ_AutoAddedByTMW')
	BEGIN
		INSERT INTO dbo.MetricCategoryItems (CategoryCode, MetricCode, Active, Sort, ShowLayersByDefault, LayerFilter)
		SELECT 'ZZ_AutoAddedByTMW', metricCode, 0, (@MaxSortForCategoryItem + sn), 0, 'ALL' FROM #TempMetrics
	END
	
	DROP TABLE #TempMetrics 
/* END: AutoAddByTMW */
GO
GRANT EXECUTE ON  [dbo].[MetricAutoAddTMWSuite] TO [public]
GO
