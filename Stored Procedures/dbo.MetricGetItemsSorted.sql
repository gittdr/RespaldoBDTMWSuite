SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetItemsSorted] (@GroupByCategory int, @ShowLayers int, @OrderBy varchar(255), @SortDirection varchar(10), @CategoryCode varchar(30) )
AS
	DECLARE @Temp1 varchar(500), @Temp2 varchar(500), @Where varchar(500), @TempSort varchar(500)
	DECLARE @sql varchar(4000)
	
	
	SET @Where = ''
	
	IF @CategoryCode <> '' 
	BEGIN
		SET @Where = ' AND t1.MetricCode IN (SELECT MetricCode FROM MetricCategoryItems WHERE CategoryCode = ''' + @CategoryCode + ''')'
	END
	
	IF @GroupByCategory = 1
	BEGIN
		SET @Temp1 = 't3.categorycode, t3.sort as categorysort, t2.sort as MetricSort, t3.captionfull AS categoryCaptionFull, '
		SET @Temp2 = 'INNER JOIN metriccategoryitems t2 ON t1.metriccode = t2.metriccode INNER JOIN metriccategory t3 ON t2.categorycode = t3.categorycode '
		If @ShowLayers = 1
		BEGIN
			SET @Where = @Where + ' AND t3.active = 1 '
		END
		ELSE
		BEGIN
			SET @Where = @Where + ' AND t3.active = 1 AND t1.MetricCode not like ''%@%'' ' 
		END
		IF @OrderBy = 'Description'
		BEGIN
			SET @TempSort = ' t3.caption, t3.CaptionFull, t1.CaptionFull '
		END
		ELSE
		BEGIN
			SET @TempSort = ' t3.caption, t1.' + @OrderBy
		END
	END
	ELSE
	BEGIN
		SET @Temp1 = ' '''' AS categorycode, 0 as categorysort, 0 as metricsort, '''' as categoryCaptionFull, '
		SET @Temp2 = ''
		IF @ShowLayers <> 1
		BEGIN
			SET @Where = @Where + ' AND t1.MetricCode NOT LIKE ''%@%'' '
		END
		IF @OrderBy = 'Description'
		BEGIN
			SET @TempSort = 't1.CaptionFull'
		END
		ELSE
		BEGIN
			SET @TempSort = @OrderBy
		END
	END

	SET @Sql = 'SELECT ' + @Temp1 + 't1.sn, t1.MetricCode, t1.Active As ItemActive, t1.Sort, t1.Caption, t1.CaptionFull, t1.ProcedureName, t1.DetailFilename, 
					t1.GoalDay, t1.GoalWeek, t1.GoalMonth, t1.GoalQuarter, t1.GoalYear, 
					t1.FormatText, t1.NumDigitsAfterDecimal, t1.PlusDeltaIsGood, t1.Cumulative 
				FROM MetricItem t1 ' + @Temp2 
          + ' WHERE 1=1 ' + @Where 
          + ' ORDER BY ' + @TempSort + ' ' + @SortDirection
          
	EXEC (@sql)
GO
GRANT EXECUTE ON  [dbo].[MetricGetItemsSorted] TO [public]
GO
