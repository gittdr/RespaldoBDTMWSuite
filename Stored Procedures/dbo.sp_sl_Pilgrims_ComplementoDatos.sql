SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_ComplementoDatos] (@dato varchar(5000),@IdCampo varchar(500) , @ConjuntoDatos varchar(500))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--select * from notes where ntb_table = 'orderheader' and nre_tablekey ='587850' and not_type is null 

	SET NOCOUNT ON;
declare @texto varchar(100) 
IF(@ConjuntoDatos = 'updateDolly')
BEGIN

update Event
set evt_dolly = @dato
 where ord_hdrnumber = (select max(ord_hdrnumber) from legheader where mov_number =@IdCampo);

 update legheader
 set lgh_dolly = @dato 
 where ord_hdrnumber = (select max(ord_hdrnumber) from legheader where mov_number =@IdCampo);
END

BEGIN
IF(@ConjuntoDatos = 'insertaMercancias')
DECLARE @stp_number int;
Declare @Material varchar(100);
DECLARE @Descripcion varchar(1000);
DECLARE @Peso Decimal(10,2);
DECLARE @Cantidad Decimal(10,2);
DECLARE @Unidad varchar(100);
DECLARE @Pedido_id int;
DECLARE @IdMercancia int;
Declare @UnidadPeso varchar(100);

		DECLARE myCursor CURSOR FORWARD_ONLY FOR
			select (Select min(stp.stp_number) from [dbo].[stops] stp where stp.ord_hdrnumber = oh.ord_hdrnumber) as stp_number,Replace(PD.[Material],'Clave pe','31211901') as [Material], PD.[Descripcion], PD.[Peso], PD.[Cantidad],PD.[unidad], PD.[Pedido_Id], PD.[IdMaterial] as IdMercancia, PD.[Unidad_Peso]
			from [dbo].[Sl_Pilgrims_Embarque] PE
			inner join [dbo].[Sl_Pilgrims_Cliente] PC on PC.Embarque_Id = PE.Embarque_Id
			inner join [dbo].[Sl_Pilgrims_Pedido] PP on PP.Client_Id = PC.Client_Id
			inner join [dbo].[Sl_Pilgrims_Detalle] PD on PD.Pedido_Id = PP.Pedido_Id
			inner join [dbo].[orderheader] oh on oh.ord_hdrnumber = (select max(ord_hdrnumber) from legheader where mov_number =@IdCampo) and oh.ord_refnum = cast(cast(PE.ruta as int) as varchar) 
			--descarga
			union
			select stp.stp_number,Replace(PD.[Material],'Clave pe','31211901') as [Material], PD.[Descripcion], PD.[Peso], PD.[Cantidad],PD.[unidad], PD.[Pedido_Id], PD.[idMaterial] as [IdMaterial], PD.[Unidad_Peso]
			from [dbo].[Sl_Pilgrims_Embarque] PE
			inner join [dbo].[Sl_Pilgrims_Cliente] PC on PC.Embarque_Id = PE.Embarque_Id
			inner join [dbo].[Sl_Pilgrims_Pedido] PP on PP.Client_Id = PC.Client_Id
			inner join [dbo].[Sl_Pilgrims_Detalle] PD on PD.Pedido_Id = PP.Pedido_Id
			inner join [dbo].[orderheader] oh on oh.ord_hdrnumber = (select max(ord_hdrnumber) from legheader where mov_number =@IdCampo) and oh.ord_refnum = cast(cast(PE.ruta as int) as varchar) 
			inner join [dbo].[stops] stp on stp.ord_hdrnumber = oh.ord_hdrnumber and stp.cmp_id = (SELECT MAX(Compania_TMW) FROM [dbo].[SL_PilgrimsTMW_CatalogoClientes] CC WHERE PC.IdClient= CC.Origen);
		OPEN myCursor;
		FETCH NEXT FROM myCursor INTO @stp_number, @Material,@Descripcion,@Peso,@Cantidad,@Unidad,@Pedido_id,@IdMercancia,@UnidadPeso;
		WHILE @@FETCH_STATUS = 0 BEGIN
		exec dx_add_neworder_freight_to_stop 'I',@stp_number, @Material, @Descripcion,@Peso, --5
					'KGM', @Cantidad,@Unidad , null,null,--10
					null,null,null,null,null,null,null,null,null,null,--20
					null,null,null,null,null,null --@Vi_consecutivo   --26
					
			FETCH NEXT FROM myCursor INTO @stp_number, @Material,@Descripcion,@Peso,@Cantidad,@Unidad,@Pedido_id,@IdMercancia,@UnidadPeso;
		END;
		CLOSE myCursor;
		DEALLOCATE myCursor;
END

END
GO
