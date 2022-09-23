SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetParameterDate2]
(
	@Heading varchar(100),
	@SubHeading varchar(100),
	@ParmName varchar(100),
	@Default datetime
)
AS
	SET NOCOUNT ON

	DECLARE @ParmValue datetime

	SELECT @ParmValue = NULL

	IF @ParmName IS NOT NULL  -- If ParmName is really not passed in...
	BEGIN

		SELECT @ParmValue = (SELECT CASE WHEN ISDATE(ParmValue) > 0 THEN CONVERT(datetime, ParmValue) ELSE NULL END
							FROM MetricParameter WITH (NOLOCK)
							WHERE Heading = @Heading 
								AND SubHeading = @SubHeading
								AND ParmName = @ParmName)

		-- The next line handles the case where the parameter exists, but is a NULL value.
--		IF EXISTS(SELECT * FROM MetricParameter WITH (NOLOCK) WHERE Heading = @Heading AND SubHeading = @SubHeading AND ParmName = @ParmName)
--			RETURN
	END

	IF (@Heading = 'Metric' OR @Heading = 'SystemMetric' )
	BEGIN
		SELECT @ParmValue = CASE WHEN ISDATE(ParmValue) > 0 THEN CONVERT(datetime, ParmValue) ELSE NULL END
				FROM MetricParameter WITH (NOLOCK)
				WHERE Heading = @Heading 
					AND SubHeading IS NULL
					AND ParmName = @ParmName

		-- The next line handles the case where the parameter exists, but is a NULL value.
--		IF EXISTS(SELECT * FROM MetricParameter WITH (NOLOCK) WHERE Heading = @Heading AND SubHeading IS NULL AND ParmName = @ParmName)
--			RETURN
	END

	IF (@ParmValue IS NULL)
		SELECT @ParmValue = @Default

	SELECT ParmValue = @ParmValue
GO
GRANT EXECUTE ON  [dbo].[MetricGetParameterDate2] TO [public]
GO
