SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInsertParameter]  (@MetricCode varchar(200), @Column_Name varchar(255), @Ordinal_Position int, @ThisParm varchar(255) )
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM MetricParameter WHERE Heading = 'MetricStoredProc' AND SubHeading = @MetricCode AND ParmName = @Column_Name)
		INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmSort, ParmValue) 
		SELECT 'MetricStoredProc', @MetricCode, @Column_Name, @Ordinal_Position, CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END

GO
GRANT EXECUTE ON  [dbo].[MetricInsertParameter] TO [public]
GO
