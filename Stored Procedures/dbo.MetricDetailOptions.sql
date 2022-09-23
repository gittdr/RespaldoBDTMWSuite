SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDetailOptions] (@MetricCode varchar(200))
AS
	SET NOCOUNT ON

	DECLARE @ProcName varchar(255)
	DECLARE @text varchar(4000)

	SELECT @ProcName = ProcedureName FROM MetricItem WHERE MetricCode = @MetricCode
	SELECT @text = (SELECT t2.text FROM sysobjects t1, syscomments t2 WHERE t1.id = t2.id -- AND t2.colid IN (1, 2) 
		AND t1.name = @ProcName AND t2.text LIKE '%DETAILOPTIONS=%')
	IF LEN(@text) > 0
	BEGIN
		SELECT DetailOptions = SUBSTRING(@text, 
			(SELECT CHARINDEX('DETAILOPTIONS=', @text, 1)) + LEN('DETAILOPTIONS='),
			(SELECT CHARINDEX(char(13), @text, (SELECT CHARINDEX('DETAILOPTIONS=', @text, 1)))) 
				- (SELECT CHARINDEX('DETAILOPTIONS=', @text, 1))
				- LEN('DETAILOPTIONS=')
			)
	END
	ELSE
	BEGIN
		SELECT DetailOptions = '' 
	END

GO
GRANT EXECUTE ON  [dbo].[MetricDetailOptions] TO [public]
GO
