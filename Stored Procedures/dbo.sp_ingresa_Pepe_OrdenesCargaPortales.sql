SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--- procedimiento para ingresar ordenes para portales pepe
CREATE  PROCEDURE [dbo].[sp_ingresa_Pepe_OrdenesCargaPortales] @No_orden Varchar(1000), @billto Varchar(1000)
AS


SET NOCOUNT ON

-- Si hay facturas ya de esa orden continua si no no pasa
	--If ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden) = 1
	--BEGIN 
	--IF ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden and ivh_invoicestatus not in ('PRN','XFR')) = 1
	--		Begin
	--			If ( SELECT count(*) FROM comentarios_cfdi_jr WHERE cc_ord_hdrnumber = @No_orden) = 0
	--			Begin
	--				insert comentarios_cfdi_jr(cc_ord_hdrnumber, cc_comentarios) values(@No_orden, @as_comentarios)
	--				Select 'La orden ya tiene comentarios para el CFDI'	
	--			End
	--			Else
	--			Begin
	--			update comentarios_cfdi_jr
	--				set cc_comentarios = @as_comentarios
	--				where cc_ord_hdrnumber = @No_orden
	--				Select 'La orden ya tenía comentarios para el CFDI previamente'	
	--			End
	--		End
	--		Else
	--		Begin
	--			Select 'La orden debe de estar en On hold o Ready to Print'	
	--		End

	--END
	--Else
	--	BEGIN
	--	Select 'La orden necesita estar facturada solo una vez'	
	--	END 
	if(@No_orden <> '' and @billto <> '' and (select count(*) from Pepe_OrdenesCargaPortales where orden = @No_orden ) = 0 )
	begin
	insert into [dbo].[Pepe_OrdenesCargaPortales]([Orden],[Billto],[Estado])
	values (@No_orden,@billto,'Creada')
	end


	--exec [dbo].[sp_ingresa_Pepe_OrdenesCargaPortales] ''
GO
