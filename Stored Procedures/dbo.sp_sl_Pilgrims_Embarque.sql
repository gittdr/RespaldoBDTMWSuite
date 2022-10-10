SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Embarque] (@ruta varchar(50),@origen varchar(100),@destino varchar(100),@tipoUnidad varchar(50),@proveedor varchar(50),@plantaPago varchar(50),@fecha varchar(50),@comentarios varchar(50),
													@remolque varchar(50),@tipoViaje varchar(50),@peso varchar(50),@unidadPiezas varchar(50),@CantidadPiezas varchar(50),@Tractor varchar(50),@remolques varchar(50), @accion int,@idEmbarque varchar(50),
													 @rutaNombre varchar(50), @distribuidor varchar(50),@idOrigen varchar(100),@idDestino varchar(100), @dolly varchar(50), @sellos varchar(50),
													  @operador varchar(50), @sellos2 varchar(50), @valePlastico varchar(50), @flejePlastico varchar(50), @valePlastico2 varchar(50), @flejePlastico2 varchar(50) )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 0)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	delete [dbo].[Sl_Pilgrims_Detalle]
	delete [dbo].[Sl_Pilgrims_Pedido]
	delete [dbo].[Sl_Pilgrims_Cliente]
	delete [dbo].[Sl_Pilgrims_Embarque]
	--truncate table [dbo].[Sl_Pilgrims_Rutas]
    -- Insert statements for procedure here
	insert into [dbo].[Sl_Pilgrims_Embarque]( Ruta, Origen, Destino, TipoUnidad, Proveedor, PlantaPago, Fecha, Comentarios, Remolque, TipoViaje, Peso, UnidadPiezas, CantidadPiezas, Tractor, Remolques,Embarque_Id, RutaNombre, Distribuidor,IdOrigen,IdDestino, Dolly, Sellos,Operador,Sellos2, ValePlastico, FlejePlastico, ValePlastico2, FlejePlastico2 )
	values (@ruta, @origen, @destino, @tipoUnidad, @proveedor, @plantaPago, @fecha, @comentarios, @remolque, @tipoViaje, @peso, @unidadPiezas, @cantidadPiezas, @tractor, @remolques,@idEmbarque, @rutaNombre, @distribuidor,@idOrigen,@idDestino, @dolly, @sellos,  @operador , @sellos2 , @valePlastico , @flejePlastico , @valePlastico2 , @flejePlastico2 )
END
IF(@accion > 0)
BEGIN
	insert into [dbo].[Sl_Pilgrims_Embarque]( Ruta, Origen, Destino, TipoUnidad, Proveedor, PlantaPago, Fecha, Comentarios, Remolque, TipoViaje, Peso, UnidadPiezas, CantidadPiezas, Tractor, Remolques,Embarque_Id, RutaNombre, Distribuidor,IdOrigen,IdDestino, Dolly, Sellos,Operador,Sellos2, ValePlastico, FlejePlastico, ValePlastico2, FlejePlastico2 )
	values (@ruta, @origen, @destino, @tipoUnidad, @proveedor, @plantaPago, @fecha, @comentarios, @remolque, @tipoViaje, @peso, @unidadPiezas, @cantidadPiezas, @tractor, @remolques,@idEmbarque, @rutaNombre, @distribuidor,@idOrigen,@idDestino, @dolly, @sellos,  @operador , @sellos2 , @valePlastico , @flejePlastico , @valePlastico2 , @flejePlastico2 )
END
END

GO
