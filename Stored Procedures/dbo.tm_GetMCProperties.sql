SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCProperties]	@sPropSN VARCHAR(12)
									,@sPropName VARCHAR(50)
									,@sMCSN VARCHAR(12)
									,@sMCCode VARCHAR(50)
									,@sResourceSN VARCHAR(12)
									,@sResourceName VARCHAR(50)
									,@sResourceType VARCHAR(12)
									,@sInstanceID VARCHAR(50)
									,@sFieldSN VARCHAR(50)
									,@sFormSN VARCHAR(50)
									,@sPropCode VARCHAR(10)
									,@sPropType VARCHAR(25)

AS

SET NOCOUNT ON

EXEC dbo.tm_GetMCProperties2 @sPropSN 
									,@sPropName
									,@sMCSN
									,@sMCCode
									,@sResourceSN
									,@sResourceName
									,@sResourceType
									,@sInstanceID
									,@sPropType
									,'' 
									,''
GO
GRANT EXECUTE ON  [dbo].[tm_GetMCProperties] TO [public]
GO
