SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpsertParameter] (@Heading varchar(200), @SubHeading varchar(100), @ParmName varchar(100), @ParmValue varchar(255) )
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM MetricParameter WHERE Heading = @Heading AND SubHeading = @SubHeading AND ParmName = @ParmName)
		UPDATE MetricParameter SET ParmValue = @ParmValue WHERE Heading = @Heading AND SubHeading = @SubHeading AND ParmName = @ParmName
	ELSE
		INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmValue) 
		SELECT @Heading, @SubHeading, @ParmName, @ParmValue

GO
GRANT EXECUTE ON  [dbo].[MetricUpsertParameter] TO [public]
GO
