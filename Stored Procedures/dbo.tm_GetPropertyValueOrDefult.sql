SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetPropertyValueOrDefult]
(
	@PropCode VARCHAR(10)
)
AS

DECLARE 
	@type INT,
	@sn INT;
SELECT @type = PropType,@sn = SN FROM dbo.tblPropertyList WHERE PropCode = @PropCode;

IF ISNULL(@type,0) = 0
	RAISERROR ('Property code must relate to a existing property', 16, 1)
	
IF @type = 1
	SELECT Value FROM dbo.tblMCTypeProperties WHERE PropSN = @sn;

ELSE 
	BEGIN
		IF @type = 2
			SELECT DefaultValue FROM dbo.tblPropertyList WHERE PropCode = @PropCode;
		ELSE
			RAISERROR ('Proc only Valid for Value and Resource Propertys', 16, 1)
	END
	


GO
GRANT EXECUTE ON  [dbo].[tm_GetPropertyValueOrDefult] TO [public]
GO
