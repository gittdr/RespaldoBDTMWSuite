SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchDogGetParmsForDisplay](@WatchName varchar(200) )
AS
	IF NOT EXISTS(SELECT * FROM sysobjects WHERE type = 'u' AND name = 'labelfile')
	BEGIN
		SELECT ParameterName, ParameterValue = ISNULL(ParameterValue, '')
		FROM WatchDogParameter (NOLOCK) 
		WHERE Heading = 'WatchDogStoredProc' 
			AND SubHeading = @WatchName 
			AND ISNULL(DisplayOnEmail, 0) = 1
	END
	ELSE
	BEGIN
		SELECT t1.ParameterName, ParameterValue = ISNULL(t1.ParameterValue, '') , 
			UserLabelName = ISNULL((SELECT Min(ISNULL(t2.userlabelname, '')) FROM labelfile t2 (NOLOCK) WHERE RIGHT(t1.ParameterName, LEN(t1.ParameterName)-1) = t2.labeldefinition), '')
		FROM WatchDogParameter t1 (NOLOCK) 
		WHERE t1.Heading = 'WatchDogStoredProc' 
			AND t1.SubHeading = @WatchName
			AND ISNULL(t1.DisplayOnEmail, 0) = 1	
	END
GO
GRANT EXECUTE ON  [dbo].[WatchDogGetParmsForDisplay] TO [public]
GO
