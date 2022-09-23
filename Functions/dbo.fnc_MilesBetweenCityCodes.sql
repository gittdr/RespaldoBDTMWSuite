SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MilesBetweenCityCodes]
	(@CityCode1 int, @CityCode2 int)

RETURNS Float
AS
	BEGIN
	
	Declare @Miles float
	Set @Miles=
		(Select TOP 1 mt_miles
		From Mileagetable
		where 
			mt_type=1
			And
			mt_originType='C'
			and
			mt_origin=Convert(varchar(50),@citycode1)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(50),@citycode2)
		)
	IF @Miles is Null 
	BEGIN
	Set @Miles=
		(Select TOP 1 mt_miles
		From Mileagetable
		where 
			mt_type=1
			And
			mt_originType='C'
			and
			mt_origin=Convert(varchar(50),@citycode2)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(50),@citycode1)
		)
	
	END	

	IF @Miles is Null 
	BEGIN
	Set @Miles=
		(Select Top 1 mt_miles
		From Mileagetable
		where 
			mt_originType='C'
			and
			mt_origin=Convert(varchar(50),@citycode2)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(50),@citycode1)
		)
	
	END	

	IF @Miles is Null 
	BEGIN
	Set @Miles=
		(Select Top 1 mt_miles
		From Mileagetable
		where 
			mt_originType='C'
			and
			mt_origin=Convert(varchar(50),@citycode1)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(50),@citycode2)
		)
	
	END	

	
	if (@Miles is NULL) SET @Miles=0
	
	return @Miles
	
	
	END
GO
GRANT EXECUTE ON  [dbo].[fnc_MilesBetweenCityCodes] TO [public]
GO
