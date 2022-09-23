SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Func_obtiene_casetas_pilgrims](@No_Orden AS VARCHAR(max))
RETURNS VARCHAR(max)
AS
BEGIN
declare
 @Origen varchar(30),
 @Destino varchar(30),
 @Remolque2 Varchar(30),
 @Ejes integer,
 @monto_casetas float


 select @Origen = ord_originpoint, 
	@Destino = ord_destpoint, 
	@Remolque2 = ord_trailer2 
 from orderheader 
 where ord_hdrnumber = @No_Orden


 IF @Remolque2 = 'UNKNOWN' 
	Select @Ejes = 5

ELSE
	Select @Ejes = 9

	-- obtiener el monto de las casetas

	select @monto_casetas = monto_iave *2
	from Costo_casetas_pilgrims
	where comp_origen = @Origen and comp_destino = @Destino and no_ejes = @Ejes





 RETURN @monto_casetas
END
GO
