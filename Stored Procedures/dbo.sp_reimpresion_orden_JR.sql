SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para cambiar el status del detalle de una orden y que se vuelva a imprimir
--DROP PROCEDURE sp_reimpresion_orden_JR
--GO

--exec sp_reimpresion_orden_JR 251026
--sp_help orderheader

CREATE PROCEDURE [dbo].[sp_reimpresion_orden_JR] @No_orden varchar(10)
AS
declare
@no_orden_num integer

select @no_orden_num = cast(@No_orden as integer)
SET NOCOUNT ON

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM invoicedetail WHERE ord_hdrnumber = @no_orden_num AND ivd_type = 'SUB' ) > 0
	BEGIN 
		Update invoicedetail set ivd_type = 'SUB1'  WHERE ivd_type = 'SUB'  and ord_hdrnumber = @no_orden_num;

		Select 'La orden ya puede ser re-impresa'	
	END
	Else
		BEGIN
		Select 'La orden tiene otro problema... hablar a TI'	
		END 








GO
