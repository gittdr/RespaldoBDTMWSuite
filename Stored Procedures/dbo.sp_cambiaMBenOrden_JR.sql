SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para cambiar el status de una orden a AVL
--DROP PROCEDURE sp_cambiaMBenOrden
--GO

--exec sp_cambiaMBenOrden 251026
--sp_help orderheader

CREATE PROCEDURE [dbo].[sp_cambiaMBenOrden_JR] @No_orden int, @Nueva_MB varchar(12)
AS


SET NOCOUNT ON
Declare
	@MBAnterior Varchar(12)

-- Si hay facturas ya de esa orden continua si no no pasa
	If ( SELECT count(*) FROM orderheader WHERE ord_hdrnumber = @No_orden and ord_status in ('AVL','DSP','PLN','STD','CMP')) =1
	BEGIN 
	SELECT @MBAnterior =  ord_fromorder FROM orderheader WHERE ord_hdrnumber = @No_orden;

		select @Nueva_MB = UPPER(@Nueva_MB);
		update orderheader set ord_fromorder = @Nueva_MB where ord_hdrnumber =	@No_orden;

		

		Insert Into Registro_Cambio_MB(orden,MBAnterior,MBNueva) values(@No_orden, @MBAnterior,@Nueva_MB);

		Select 'La orden ya esta actualizada'	

		commit;
	END
	Else
		BEGIN
		Select 'La orden no existe ó Necesita NO estar Completada ni Cancelada...'
		END 






GO
GRANT EXECUTE ON  [dbo].[sp_cambiaMBenOrden_JR] TO [public]
GO
