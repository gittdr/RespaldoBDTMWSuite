SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[tmail_CheckCallTypeCodes]

AS

SET NOCOUNT ON 

	if NOT EXISTS(SELECT * 
					FROM LabelFile (NOLOCK)
					WHERE LabelDefinition = 'CheckCallEvent')
		SELECT Name, abbr 
		FROM EventCodeTable (NOLOCK) 
	else
		SELECT Name, abbr 
		FROM LabelFile (NOLOCK)
		WHERE LabelDefinition = 'CheckCallEvent'

GRANT EXECUTE ON dbo.tmail_CheckCallTypeCodes TO public
GO
