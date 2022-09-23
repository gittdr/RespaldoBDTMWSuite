SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPerceivedDate] 
(
	@ExecuteOnly int = 0, 
	@VirtualDate datetime = NULL OUTPUT, 
	@Adjusted int = 0 
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	DECLARE @pDate varchar(255)
	DECLARE @RunPreviousDayYN varchar(1)

	CREATE TABLE #tempPDate (pDate datetime )
	SET NOCOUNT ON

	SELECT @pDate = ParmValue from metricparameter WITH (NOLOCK) WHERE Heading = 'MetricGeneral' AND SubHeading = 'DEBUG' AND ParmName = 'MockDate'
	IF (@pDate IS NULL)
		SELECT @pDate = CAST(DatePart(yyyy, GETDATE()) AS char(4)) 
				+ RIGHT('0' + CAST(DATEPART(mm, GETDATE()) AS varchar(2)), 2) 
				+ RIGHT('0' + CAST(DATEPART(dd, GETDATE()) AS varchar(2)), 2)

        EXEC MetricGetParameterText @RunPreviousDayYN OUTPUT, 'Y', 'Config', 'All', 'Process_And_Show_For_Previous_Day_YN'
	IF @Adjusted = 1 
		SELECT @pDate = CASE WHEN @RunPreviousDayYN = 'Y' THEN DATEADD(day, -1, @pDate) ELSE @pDate END

	INSERT INTO #tempPDate 
	SELECT CONVERT(datetime, @pDate) 

	SELECT @VirtualDate = pDate FROM #tempPDate

	IF @ExecuteOnly = 0
		SELECT pDate FROM #tempPDate

	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[MetricGetPerceivedDate] TO [public]
GO
