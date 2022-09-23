SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Rutas] (@accion int )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
IF(@accion = 1)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @ruta as varchar(100)
declare @origen as varchar(100) 
declare @destino as varchar(100) 
declare @clientes as varchar(100) 
declare @Cargado as varchar(100) 
declare @Cajas as varchar(100) 
declare @CargaTon as varchar(100) 
declare @CajasDetalle as varchar(5000) 
declare @PesoDetalle as varchar(5000) 
declare @FacturaDetalle as varchar(max) 
declare @ClienteDescripcion as varchar(max) declare @Cajas2 as varchar(100) 
declare @CargaTon2 as varchar(100) declare @Dolly as varchar(100) declare @Sellos as varchar(100) 
declare @Operador as varchar(100) declare @Sellos2 as varchar(100) declare @ValePlastico as varchar(100) 
declare @FlejePlastico as varchar(100) declare @ValePlastico2 as varchar(100) declare @FlejePlastico2 as varchar(100) 
declare @Remolque1 as varchar(100) declare @Remolque2 as varchar(100) declare @Remisiones2 as varchar(100) 
declare @CajasDetalle2 as varchar(5000) declare @PesoDetalle2 as varchar(5000) declare @FacturaDetalle2 as varchar(max) 
declare @ClienteDescripcion2 as varchar(max) declare @FlagInsert as varchar(100)

DECLARE authors_cursor CURSOR FOR 
	select vEmb.ruta, vEmb.origen, vEmb.destino, vEmb.clientes,null,
	
	(SELECT   SUM(cast([dbo].[Sl_Pilgrims_Detalle].[Cantidad] as decimal))     
		FROM            dbo.Sl_Pilgrims_Cliente INNER JOIN
                         dbo.Sl_Pilgrims_Embarque ON dbo.Sl_Pilgrims_Cliente.Embarque_Id = dbo.Sl_Pilgrims_Embarque.Embarque_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Pedido ON dbo.Sl_Pilgrims_Cliente.Client_Id = dbo.Sl_Pilgrims_Pedido.Client_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Detalle ON dbo.Sl_Pilgrims_Pedido.Pedido_Id = dbo.Sl_Pilgrims_Detalle.Pedido_Id
		where  dbo.Sl_Pilgrims_Embarque.ruta=vEmb.ruta and dbo.Sl_Pilgrims_Pedido.Caja = '1') cantidad,

    (SELECT   SUM(cast( [dbo].[Sl_Pilgrims_Detalle].[Peso] as decimal))     
		FROM            dbo.Sl_Pilgrims_Cliente INNER JOIN
                         dbo.Sl_Pilgrims_Embarque ON dbo.Sl_Pilgrims_Cliente.Embarque_Id = dbo.Sl_Pilgrims_Embarque.Embarque_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Pedido ON dbo.Sl_Pilgrims_Cliente.Client_Id = dbo.Sl_Pilgrims_Pedido.Client_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Detalle ON dbo.Sl_Pilgrims_Pedido.Pedido_Id = dbo.Sl_Pilgrims_Detalle.Pedido_Id
		where  dbo.Sl_Pilgrims_Embarque.ruta=vEmb.ruta and dbo.Sl_Pilgrims_Pedido.Caja = '1'),
vEmb.[Cajas],vEmb.[Peso],vEmb.[Facturas],vEmb.[ClienteDescripcion],

	(SELECT   SUM(cast([dbo].[Sl_Pilgrims_Detalle].[Cantidad] as decimal))     
		FROM            dbo.Sl_Pilgrims_Cliente INNER JOIN
                         dbo.Sl_Pilgrims_Embarque ON dbo.Sl_Pilgrims_Cliente.Embarque_Id = dbo.Sl_Pilgrims_Embarque.Embarque_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Pedido ON dbo.Sl_Pilgrims_Cliente.Client_Id = dbo.Sl_Pilgrims_Pedido.Client_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Detalle ON dbo.Sl_Pilgrims_Pedido.Pedido_Id = dbo.Sl_Pilgrims_Detalle.Pedido_Id
		where  dbo.Sl_Pilgrims_Embarque.ruta=vEmb.ruta and dbo.Sl_Pilgrims_Pedido.Caja = '2'),

    (SELECT   SUM(cast( [dbo].[Sl_Pilgrims_Detalle].[Peso] as decimal))     
		FROM            dbo.Sl_Pilgrims_Cliente INNER JOIN
                         dbo.Sl_Pilgrims_Embarque ON dbo.Sl_Pilgrims_Cliente.Embarque_Id = dbo.Sl_Pilgrims_Embarque.Embarque_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Pedido ON dbo.Sl_Pilgrims_Cliente.Client_Id = dbo.Sl_Pilgrims_Pedido.Client_Id 
						 INNER JOIN dbo.Sl_Pilgrims_Detalle ON dbo.Sl_Pilgrims_Pedido.Pedido_Id = dbo.Sl_Pilgrims_Detalle.Pedido_Id
		where  dbo.Sl_Pilgrims_Embarque.ruta=vEmb.ruta and dbo.Sl_Pilgrims_Pedido.Caja = '2'),
vEmb.[Dolly],vEmb.[Sellos],vEmb.[Operador],vEmb.[Sellos2],vEmb.[ValePlastico],vEmb.[FlejePlastico],vEmb.[ValePlastico2],vEmb.[FlejePlastico2],vEmb.[Remolque],vEmb.[Remolques],
vEmb.[Clientes2],vEmb.[Cajas2],vEmb.[Peso2],vEmb.[Facturas2],vEmb.[ClienteDescripcion2],1 AS idBitacora
	

from vista_S1_Pilgrims_Embarques vEmb

where vEmb.ruta not in (select ruta from [dbo].[Sl_Pilgrims_Rutas])

OPEN authors_cursor 
FETCH NEXT FROM authors_cursor INTO 
 @ruta, 
 @origen,  
 @destino,  
 @clientes,  
 @Cargado  ,
 @Cajas  ,
 @CargaTon,  
 @CajasDetalle,  
 @PesoDetalle  ,
 @FacturaDetalle,  
 @ClienteDescripcion,   @Cajas2,  
 @CargaTon2,   @Dolly,   @Sellos,  
 @Operador,   @Sellos2,   @ValePlastico,  
 @FlejePlastico,   @ValePlastico2,   @FlejePlastico2,  
 @Remolque1,   @Remolque2,   @Remisiones2,  
 @CajasDetalle2,   @PesoDetalle2,   @FacturaDetalle2,  
 @ClienteDescripcion2,   @FlagInsert 

WHILE @@FETCH_STATUS = 0 
BEGIN

print 'entre al ciclo del cursor' + @ruta

	if(@ruta is not null)
begin
	 --Insert statements for procedure here
	insert into [dbo].[Sl_Pilgrims_Rutas](ruta, origen, destino, clientes,[Cargado],[Cajas],[CargaTon],[CajasDetalle],[PesoDetalle],[FacturaDetalle],[ClienteDescripcion],[Cajas2],[CargaTon2]
											,[Dolly],[Sellos],[Operador],[Sellos2],[ValePlastico],[FlejePlastico],[ValePlastico2],[FlejePlastico2],[Remolque1],[Remolque2]
											,[Remisiones2],[CajasDetalle2],[PesoDetalle2],[FacturaDetalle2],[ClienteDescripcion2],[FlagInsert])
	values(
	 @ruta, 
	 @origen,  
	 @destino,  
	 @clientes,  
	 @Cargado  ,
	 @Cajas  ,
	 @CargaTon,  
	 @CajasDetalle,  
	 @PesoDetalle  ,
	 @FacturaDetalle,  
	 @ClienteDescripcion,   @Cajas2,  
	 @CargaTon2,   @Dolly,   @Sellos,  
	 @Operador,   @Sellos2,   @ValePlastico,  
	 @FlejePlastico,   @ValePlastico2,   @FlejePlastico2,  
	 @Remolque1,   @Remolque2,   @Remisiones2,  
	 @CajasDetalle2,   @PesoDetalle2,   @FacturaDetalle2,  
	 @ClienteDescripcion2,   @FlagInsert 
	)	
	print 'entre a insertar'

FETCH NEXT FROM authors_cursor

INTO @ruta, 
 @origen,  
 @destino,  
 @clientes,  
 @Cargado  ,
 @Cajas  ,
 @CargaTon,  
 @CajasDetalle,  
 @PesoDetalle  ,
 @FacturaDetalle,  
 @ClienteDescripcion,   @Cajas2,  
 @CargaTon2,   @Dolly,   @Sellos,  
 @Operador,   @Sellos2,   @ValePlastico,  
 @FlejePlastico,   @ValePlastico2,   @FlejePlastico2,  
 @Remolque1,   @Remolque2,   @Remisiones2,  
 @CajasDetalle2,   @PesoDetalle2,   @FacturaDetalle2,  
 @ClienteDescripcion2,   @FlagInsert 

 	

end

END 
CLOSE authors_cursor 
DEALLOCATE authors_cursor

END

END
GO
