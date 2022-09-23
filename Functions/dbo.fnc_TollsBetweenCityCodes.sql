SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select [dbo].[fnc_TollsBetweenCityCodes] (43435,73528,7)
-- Select * From Mileagetable where mt_type = 7  and mt_originType='C' and  mt_DestinationType='C' 

CREATE FUNCTION [dbo].[fnc_TollsBetweenCityCodes]
	(@CityCode1 int, @CityCode2 int, @mtable int)

RETURNS Float
AS
	BEGIN
	
	Declare @Tolls float
	Set @Tolls=
		(Select TOP 1 mt_tolls_cost
       From Mileagetable
		where 
			mt_type=@mtable 
			And
			mt_originType='C'
			and
			mt_origin=Convert(varchar(20),@CityCode1)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(20),@CityCode2)
		)

	IF @Tolls is Null 
	BEGIN
	Set @Tolls =
		(Select TOP 1  mt_tolls_cost
		From Mileagetable
		where 
			mt_type=@mtable 
			And
			mt_originType='C'
			and
			mt_origin=Convert(varchar(50),@CityCode2)
			and
			mt_DestinationType='C'
			and
			mt_Destination=Convert(varchar(50),@CityCode1)
		)
	
	END	
	
	if (@Tolls is NULL) SET @Tolls=0
	
	return @Tolls
	
	
	END
GO
