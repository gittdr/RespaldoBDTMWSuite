SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_AirMilesBetweenCompanies]
	(@CmpID1 varchar(255), @CmpID2 varchar(255))

RETURNS Float
AS
	BEGIN
	
	Declare @lat1 float
	Declare @lat2 float
	
	Declare @long1 float
	Declare @long2 float
	Declare @AirMiles float

	If  @CmpID1 is NULL RETURN 0
	If  @CmpID2 is NULL RETURN 0
	If  RTRIM(LTRIM(@CmpID1)) = '' RETURN 0
	If  RTRIM(LTRIM(@CmpID2)) = '' RETURN 0

	Set @lat1= (
		Select isnull(cmp_latseconds, cty.cty_latitude * 3600) 
		from company 
		LEFT OUTER JOIN dbo.city cty (NOLOCK) 
		ON dbo.company.cmp_city = cty.cty_code 
		where cmp_id=@CmpID1)
	Set @lat2= (
		Select isnull(cmp_latseconds, cty.cty_latitude * 3600) 
		from company 
		LEFT OUTER JOIN dbo.city cty (NOLOCK) 
		ON dbo.company.cmp_city = cty.cty_code 
		where cmp_id=@CmpID2)
	Set @long1= (
		Select isnull(cmp_longseconds, cty.cty_longitude * 3600) 
		from company 
		LEFT OUTER JOIN dbo.city cty (NOLOCK) 
		ON dbo.company.cmp_city = cty.cty_code 
		where cmp_id=@CmpID1)
	Set @long2= (
		Select isnull(cmp_longseconds, cty.cty_longitude * 3600) 
		from company 
		LEFT OUTER JOIN dbo.city cty (NOLOCK) 
		ON dbo.company.cmp_city = cty.cty_code 
		where cmp_id=@CmpID2)

	Set	@AirMiles=dbo.fnc_AirMilesBetweenLatLongSeconds(@lat1, @lat2, @long1, @long2)
	
	return @AirMiles
	
	
	END
GO
