SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertGroup] (@GroupName varchar(50) ) 
AS
	SET NOCOUNT ON
	DECLARE @Success int

--insert into metricgroup (groupName) select @GroupName + CONVERT(varchar(10), RAND(Datepart(ms, getdate())) * RAND(Datepart(second, getdate())))

	IF EXISTS(SELECT sn FROM MetricGroup WHERE GroupName = @GroupName) 
		SET @Success = 0
	ELSE
	BEGIN
		INSERT INTO MetricGroup (GroupName) SELECT @GroupName 
		SELECT @Success = sn FROM MetricGroup WHERE GroupName = @GroupName
	END

	SELECT @Success
GO
GRANT EXECUTE ON  [dbo].[MetricInsertGroup] TO [public]
GO
