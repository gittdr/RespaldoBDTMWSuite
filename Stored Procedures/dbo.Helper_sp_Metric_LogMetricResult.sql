SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC  [dbo].[Helper_sp_Metric_LogMetricResult]
	(
		@ProcName VARCHAR(30),
		@Result decimal(20, 5) , 
		@ThisCount decimal(20, 5) , 
		@ThisTotal decimal(20, 5) , 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int
	)

/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS

	Insert into MetricTemp
	Select @ProcName,@Result,@ThisCount,@ThisTotal, @DateStart,@DateEnd,@UseMetricParms,@ShowDetail	
		
-- Exec Helper_sp_Metric_LogMetricResult '', @Result,@ThisCount,@ThisTotal, @DateStart,@DateEnd,@UseMetricParms,@ShowDetail	
-- *********************************************************************************************
GO
GRANT EXECUTE ON  [dbo].[Helper_sp_Metric_LogMetricResult] TO [public]
GO
