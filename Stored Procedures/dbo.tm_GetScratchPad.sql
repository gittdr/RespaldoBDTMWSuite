SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetScratchPad] (
	@Type 		VARCHAR(8),		--** Typically "TRC", but possibly DRV, TRL, CAR.  Make length 8 to allow TRL1 in double-byte version / international.
	@TypeValue 	VARCHAR(13),	--** Typically a tractor (trc_number) or driver (mpp_id) number.  
	@Key1 		VARCHAR(20)		--** Typically "lgh_number", but possibly "ord_hdrnumber" or "mov_number".
	)
AS

SET NOCOUNT ON

	IF EXISTS(SELECT Type 
				FROM tblScratchPad (NOLOCK)
				WHERE Type = @Type AND TypeValue = @TypeValue AND Key1 = @Key1)
		SELECT '1' AS RetStatus, DateIns, DateUpd, Type, TypeValue, Key1, Key1Value
		FROM tblScratchPad (NOLOCK) 
		WHERE Type = @Type AND TypeValue = @TypeValue AND Key1 = @Key1
	ELSE
		SELECT '0' AS RetStatus, '' As DateIns, '' As DateUpd, @Type As Type, @TypeValue As TypeValue, @Key1 As Key1, '' As Key1Value
GO
GRANT EXECUTE ON  [dbo].[tm_GetScratchPad] TO [public]
GO
