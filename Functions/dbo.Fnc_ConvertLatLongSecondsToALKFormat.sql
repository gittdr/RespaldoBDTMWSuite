SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Fnc_ConvertLatLongSecondsToALKFormat]
	(@LatSeconds int, @LongSeconds int)

RETURNS Varchar(20)
AS
BEGIN
	Declare @Ret Varchar(20)

	Declare @DecimalLat Decimal(8,3)
	Declare @DecimalLong Decimal(8,3)
	Declare @strLat Varchar(10)
	Declare @StrLong Varchar(10)


	Set @DecimalLat= Convert(decimal(8,3),(convert(float,@LatSeconds)/3600))
	Set @DecimalLong =Convert(decimal(8,3),(convert(float,@LongSeconds)/3600))

	Set @strLat =Right( '0'+ convert(varchar(10),@DecimalLat),7)+'N,'
	Set @strLong =Right( '0'+ convert(varchar(10),@DecimalLong),7)+'w'

	

	Set @Ret = @strLat + @strLong
Return @Ret

End

GO
