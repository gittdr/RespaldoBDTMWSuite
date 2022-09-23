SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--- procedimiento para ingresar el comentario del cfdi mediante la orden de la invoice

CREATE  PROCEDURE [dbo].[sp_obtiene_mb_invoice] @invoice varchar(50), @as_comentarios Varchar(max)
AS

SET NOCOUNT ON
Declare @No_orden as varchar(50)

--si es master ejecuta
If (SELECT count(*) FROM invoiceheader WHERE ivh_invoicenumber = @invoice and ivh_mbnumber <> 0 ) = 1 
begin
set @No_orden = (select ord_hdrnumber 
					FROM invoiceheader 
					WHERE  ivh_hdrnumber = 
								(Select MAX(ivh_hdrnumber) from invoiceheader where ivh_mbnumber=
																			(Select ivh_mbnumber FROM invoiceheader WHERE ivh_invoicenumber = @invoice)))

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden) = 1
	BEGIN 
	IF ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden and ivh_invoicestatus not in ('XFR')) = 1
			Begin
				If ( SELECT count(*) FROM comentarios_cfdi_jr WHERE cc_ord_hdrnumber = @No_orden) = 0
				Begin
					insert comentarios_cfdi_jr(cc_ord_hdrnumber, cc_comentarios) values(@No_orden, @as_comentarios)
					update invoiceheader
					set ivh_remark = @as_comentarios
						 where ord_hdrnumber = @No_orden
					Select 'La orden ya tiene comentarios para el CFDI'	
				End
				Else
				Begin
				update comentarios_cfdi_jr
					set cc_comentarios = @as_comentarios
					where cc_ord_hdrnumber = @No_orden

					update invoiceheader
					set ivh_remark = @as_comentarios
						 where ord_hdrnumber = @No_orden
					Select 'La orden ya tenía comentarios para el CFDI previamente'	
				End
			End
			Else
			Begin
				Select 'La orden debe de estar en On hold o Ready to Print'	
			End

	END
	Else
		BEGIN
		Select 'La orden necesita estar facturada solo una vez'	
		END 
	

end
--si es single invoice ejecutar esto
else IF (SELECT count(*) FROM invoiceheader WHERE ivh_invoicenumber = @invoice and ivh_mbnumber = 0 ) = 1 
begin
set @No_orden = (select ord_hdrnumber 
					FROM invoiceheader 
					WHERE   ivh_invoicenumber = @invoice)

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden) = 1
	BEGIN 
	IF ( SELECT count(*) FROM invoiceheader WHERE ord_hdrnumber = @No_orden and ivh_invoicestatus not in ('XFR')) = 1
			Begin
				If ( SELECT count(*) FROM comentarios_cfdi_jr WHERE cc_ord_hdrnumber = @No_orden) = 0
				Begin
					insert comentarios_cfdi_jr(cc_ord_hdrnumber, cc_comentarios) values(@No_orden, @as_comentarios)

					update invoiceheader
					set ivh_remark = @as_comentarios
						 where ord_hdrnumber = @No_orden
					Select 'La orden ya tiene comentarios para el CFDI'	
				End
				Else
				Begin
				update comentarios_cfdi_jr
					set cc_comentarios = @as_comentarios
					where cc_ord_hdrnumber = @No_orden

					update invoiceheader
					set ivh_remark = @as_comentarios
						 where ord_hdrnumber = @No_orden
					Select 'La orden ya tenía comentarios para el CFDI previamente'	
				End
			End
			Else
			Begin
				Select 'La orden debe de estar en On hold o Ready to Print'	
			End

	END
	Else
		BEGIN
		Select 'La orden necesita estar facturada solo una vez'	
		END 
	


end 
GO
