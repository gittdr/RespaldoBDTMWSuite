SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_GetLTSL2Setting] (
@settingName varchar(255)
)

AS

	DECLARE @ReturnValue int 

	IF (SELECT COUNT(1) FROM dx_lookup
		WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
		and dx_lookuprawdatavalue = @settingName and dx_lookuptranslatedvalue = '1') = 1     
					   SET @ReturnValue = 1
	ELSE
					   SET @ReturnValue = 0
					   
	RETURN @ReturnValue

GO
GRANT EXECUTE ON  [dbo].[dx_GetLTSL2Setting] TO [public]
GO
