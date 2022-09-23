SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[MetricCvtDateToText](@DateIn datetime)
RETURNS varchar(21) -- YYYYMMDD HH:NN:SS.MMM
BEGIN
	DECLARE @sReturn varchar(21)
	
	SELECT @sReturn = 
			CONVERT(varchar(4), DATEPART(year, @DateIn))
		+ 	'-'
		+ 	RIGHT('0' + CONVERT(varchar(2), DATEPART(month, @DateIn)), 2)
		+ 	'-'
		+ 	RIGHT('0' + CONVERT(varchar(2), DATEPART(day, @DateIn)), 2)
		+   ' '
		+ 	RIGHT('0' + CONVERT(varchar(2), DATEPART(hour, @DateIn)), 2)
		+ 	':'
		+ 	RIGHT('0' + CONVERT(varchar(2), DATEPART(minute, @DateIn)), 2)
		+ 	':'
		+ 	RIGHT('0' + CONVERT(varchar(2), DATEPART(second, @DateIn)), 2)

	RETURN @sReturn
END
GO
GRANT EXECUTE ON  [dbo].[MetricCvtDateToText] TO [public]
GO
