SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SetScratchPad] (
	@Type 		VARCHAR(8),		--** Typically "TRC", but possibly DRV, TRL, CAR.  Make length 8 to allow TRL1 in double-byte version / international.
	@TypeValue 	VARCHAR(13),	--** Typically a tractor (trc_number) or driver (mpp_id) number.  
	@Key1 		VARCHAR(20),	--** Typically "lgh_number", but possibly "ord_hdrnumber" or "mov_number".
	@Key1Value 	VARCHAR(50)		--** Typically a leg header number.
	)
AS

SET NOCOUNT ON

	IF EXISTS(SELECT Type 
				FROM tblScratchPad (NOLOCK)
				WHERE Type = @Type AND TypeValue = @TypeValue AND Key1 = @Key1)
	BEGIN
		UPDATE tblScratchPad 
			SET Key1Value = @Key1Value, DateUpd = GETDATE() 
			WHERE Type = @Type AND TypeValue = @TypeValue AND Key1 = @Key1
	END
	ELSE
	BEGIN
		INSERT INTO tblScratchPad (Type, TypeValue, Key1, Key1Value)
			VALUES (@Type, @TypeValue, @Key1, @Key1Value)

	END
	
SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[tm_SetScratchPad] TO [public]
GO
