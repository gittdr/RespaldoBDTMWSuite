SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para completar las ordenes especiales del cliente de Liverpool Patieros
--DROP PROCEDURE dx_sp_completa_orden_DX_JR
--GO

--exec dxsp_completa_orden_DX_JR 319846
--sp_help orderheader

create PROCEDURE [dbo].[dx_sp_completa_orden_DX_JR] @No_orden int
AS
DECLARE @No_Movimiento integer

BEGIN

select @No_Movimiento = mov_number from orderheader where ord_hdrnumber = @No_orden

--Cambia el status del event de 'OPN' a 'DNE' en base al movimiento
	--select evt_mov_number, evt_status, * from event where ord_hdrnumber = 292664

	Update event set evt_status = 'DNE' Where evt_mov_number = @No_Movimiento;


-- En la tabla Orderheader cambia el status a CMP y de la factura a 'AVL'
-- select mov_number, ord_status,ord_invoicestatus ,* from orderheader where ord_hdrnumber = 292664

	Update orderheader set ord_status = 'CMP', ord_invoicestatus = 'AVL'  where mov_number = @No_Movimiento

-- En la tabla assetassignment cambia el status de a 'CMP'
-- al parecer no se llena esta tabla
	--select * from assetassignment where mov_number = 319846
	--Update assetassignment set asgn_status = 'CMP'  where mov_number = 267257

-- Stops cambiar el status stp_lgh_status de 'AVL' a 'CMP'y del campo stp_status de 'OPN' a  'DNE'
	--select stp_lgh_status, stp_status,* from stops where ord_hdrnumber = 292664
	Update stops set stp_lgh_status = 'CMP', stp_status = 'DNE' where mov_number = @No_Movimiento and 
		stp_number = (Select min(stp_number) from stops where mov_number = @No_Movimiento)

		Update stops set stp_lgh_status = 'CMP', stp_status = 'DNE' where mov_number = @No_Movimiento and 
		stp_number = (Select max(stp_number) from stops where mov_number = @No_Movimiento)


-- Tablas legheader cambio de status de 'AVL' a 'CMP'
Update legheader set lgh_outstatus = 'CMP' where mov_number = @No_Movimiento



SET NOCOUNT ON


END 
GO
