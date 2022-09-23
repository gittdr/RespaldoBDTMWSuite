SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCreateThisMetric](@CategoryCode varchar(30), @MetricCode varchar(255), @Format varchar(12), @PlusDeltaIsGood int, @Cumulative int, @ProcedureName varchar(255),
								@Parm1Name varchar(100) = '', @Parm1Value varchar(100) = '', @Parm2Name varchar(100) = '', @Parm2Value varchar(100) = '', 
								@Parm3Name varchar(100) = '', @Parm3Value varchar(100) = '', @Parm4Name varchar(100) = '', @Parm4Value varchar(100) = '', 
								@Parm5Name varchar(100) = '', @Parm5Value varchar(100) = '', @Parm6Name varchar(100) = '', @Parm6Value varchar(100) = '', 
								@Parm7Name varchar(100) = '', @Parm7Value varchar(100) = '', @Parm8Name varchar(100) = '', @Parm8Value varchar(100) = ''
)
AS
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM metricitem t1 (NOLOCK) WHERE 
					MetricCode = @MetricCode
					AND ( (@Parm1Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm1Name AND ParmValue = @Parm1Value) )
					AND ( (@Parm2Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm2Name AND ParmValue = @Parm2Value) )
					AND ( (@Parm3Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm3Name AND ParmValue = @Parm3Value) )
					AND ( (@Parm4Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm4Name AND ParmValue = @Parm4Value) )
					AND ( (@Parm4Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm5Name AND ParmValue = @Parm5Value) )
					AND ( (@Parm6Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm6Name AND ParmValue = @Parm6Value) )
					AND ( (@Parm7Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm7Name AND ParmValue = @Parm7Value) )
					AND ( (@Parm8Name = '') OR EXISTS(SELECT * FROM metricparameter (NOLOCK) WHERE SubHeading = @MetricCode AND ParmName = @Parm8Name AND ParmValue = @Parm8Value) )
				)
	BEGIN

		DECLARE @NumDigitsAfterDecimal int
		IF @Format IN ('PCT', 'CURR') SET @NumDigitsAfterDecimal = 2
		ELSE SET @NumDigitsAfterDecimal = 0

		-- Create entry in MetricItem.
		IF NOT EXISTS(SELECT * FROM MetricItem WHERE metriccode = @MetricCode)
		BEGIN
			INSERT INTO MetricItem (MetricCode, Caption, CaptionFull, Active, Sort, FormatText, PlusDeltaIsGood, Cumulative, ProcedureName, NumDigitsAfterDecimal)
			SELECT @MetricCode, @MetricCode, @MetricCode, 0, 1, @Format, @PlusDeltaIsGood, @Cumulative, @ProcedureName, @NumDigitsAfterDecimal

			-- Add parameters.
			IF @Parm1Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm1Name AND ParmName = @Parm1Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm1Name, @Parm1Value

			IF @Parm2Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm2Name AND ParmName = @Parm2Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm2Name, @Parm2Value

			IF @Parm3Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm3Name AND ParmName = @Parm3Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm3Name, @Parm3Value

			IF @Parm4Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm4Name AND ParmName = @Parm4Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm4Name, @Parm4Value

			IF @Parm5Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm5Name AND ParmName = @Parm5Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm5Name, @Parm5Value

			IF @Parm6Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm6Name AND ParmName = @Parm6Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm6Name, @Parm6Value

			IF @Parm7Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm7Name AND ParmName = @Parm7Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm7Name, @Parm7Value

			IF @Parm8Name <> '' AND NOT EXISTS(SELECT * FROM metricparameter WHERE Heading = 'MetricStoredProc' AND Subheading = @MetricCode AND ParmName = @Parm8Name AND ParmName = @Parm8Value)
				INSERT INTO MetricParameter (Heading, Subheading, ParmName, ParmValue)
				SELECT 'MetricStoredProc', @MetricCode, @Parm8Name, @Parm8Value

			-- Add category if not exists.
			IF NOT EXISTS(SELECT * FROM metriccategory WHERE categoryCode = @CategoryCode)
			BEGIN
				INSERT INTO MetricCategory (CategoryCode, Active, Sort, ShowTime, Caption, CaptionFull)
				SELECT @CategoryCode, 1, 1, 0, @CategoryCode, @CategoryCode
			END

			-- Assign to category.
			IF NOT EXISTS(SELECT * FROM metriccategoryitems WHERE CategoryCode = @CategoryCode AND MetricCode = @MetricCode)
				INSERT INTO MetricCategoryItems (CategoryCode, MetricCode, Active, Sort, ShowLayersByDefault, LayerFilter)
				SELECT @CategoryCode, @MetricCode, 1, 1, 0, 'ALL'
		END

	END
GO
