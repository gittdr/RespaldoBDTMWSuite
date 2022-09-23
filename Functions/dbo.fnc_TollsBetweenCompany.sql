SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select [dbo].[fnc_TollsBetweenCompany] ('SAYLAPRE','SAYER',7)
-- Select TOP 1 mt_tolls_cost From Mileagetable where mt_type = 7  and	mt_originType='O' and mt_origin='SAYER' and mt_DestinationType='O' and mt_Destination='SAYLAPRE'


CREATE FUNCTION [dbo].[fnc_TollsBetweenCompany]
	(@Company1 varchar(20), @Company2 varchar (20), @mtable int)

RETURNS Float
AS
	BEGIN
	
	Declare @Tolls float
    Declare @Ccity1 int
    Declare @Ccity2 int

	Set @Tolls=
		(Select TOP 1 mt_tolls_cost
       From Mileagetable
		where 
			mt_type=@mtable 
			And
			mt_originType='O'
			and
			mt_origin= @Company1
			and
			mt_DestinationType='O'
			and
			mt_Destination= @Company2
		)

	IF @Tolls is Null 
	BEGIN
	Set @Tolls =
		(Select TOP 1  mt_tolls_cost
		From Mileagetable
		where 
			mt_type=@mtable 
			And
			mt_originType='O'
			and
			mt_origin= @Company2 
			and
			mt_DestinationType='O'
			and
			mt_Destination= @Company1
		)
	
	END	

---- si no encuentra las casetas por companyid las buscara por ciudad

IF @Tolls is Null 
	BEGIN
    
     Set @Ccity1 = ( select m.cmp_city from  company m  where cmp_id = @Company1 )
     Set @Ccity2 = ( select m.cmp_city from  company m  where cmp_id = @Company2 )

     set @Tolls = (select [dbo].[fnc_TollsBetweenCityCodes] (@Ccity1,@Ccity2,@mtable))

	END	


-- si de plano no encontro casetas en ningun lado regresa 0

	if (@Tolls is NULL) SET @Tolls=0
	
	return @Tolls
	
	
	END
GO
