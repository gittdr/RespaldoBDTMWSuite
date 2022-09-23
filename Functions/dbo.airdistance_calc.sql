SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[airdistance_calc] (@ocmp_id VARCHAR (8), @olat1 DECIMAL(38,20), @olong1 DECIMAL(38,20), @olat2 DECIMAL(38,20), @olong2 DECIMAL(38,20), 
										 @dcmp_id VARCHAR (8), @dlat1 DECIMAL(38,20), @dlong1 DECIMAL(38,20), @dlat2 DECIMAL(38,20), @dlong2 DECIMAL(38,20))
RETURNS DECIMAL (38,20)
AS
BEGIN
	DECLARE @distance 		DECIMAL(38,20)
	
	IF @olat1 IS NULL OR @olong1 IS NULL OR @ocmp_id = 'UNKNOWN'
	BEGIN
		SELECT @olat1 = @olat2, @olong1 = @olong2
	END

	IF @dlat1 IS NULL OR @dlong1 IS NULL OR @dcmp_id = 'UNKNOWN'
	BEGIN
		SELECT @dlat1 = @dlat2, @dlong1 = @dlong2
	END

	SET @distance = dbo.tmw_airdistance_fn (@olat1, @olong1, @dlat1, @dlong1)
	RETURN @distance
END

GO
GRANT EXECUTE ON  [dbo].[airdistance_calc] TO [public]
GO
