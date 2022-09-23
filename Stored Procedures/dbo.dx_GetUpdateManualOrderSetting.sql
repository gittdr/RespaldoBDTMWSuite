SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_GetUpdateManualOrderSetting] 

AS

	DECLARE @ReturnValue int 
	IF (SELECT COUNT(1) FROM dx_lookup
		WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
		and (dx_lookuprawdatavalue = 'UpdateManualOrder' or dx_lookuprawdatavalue = 'UpdateValidation')
		and dx_lookuptranslatedvalue = '1') > 0
					   SET @ReturnValue = 1
    ELSE
					   SET @ReturnValue = 0
					   
	SELECT Convert(bit,@ReturnValue)
	RETURN @ReturnValue
GO
GRANT EXECUTE ON  [dbo].[dx_GetUpdateManualOrderSetting] TO [public]
GO
