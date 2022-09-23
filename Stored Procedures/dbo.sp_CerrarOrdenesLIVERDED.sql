SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Author,,Name> Linda
-- Create date: <Create Date,,> 26/11/19
-- Description:	<Description,,> Cerrar todas las ordenes creadas por DX para el BillTo LIVERDED revtype 3 = HED 10 días.

-- Exec [dbo].[sp_CerrarOrdenesLIVERDED] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_CerrarOrdenesLIVERDED] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	-- Legheader
		UPDATE legheader SET lgh_outstatus = 'CMP' WHERE ord_hdrnumber in 
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'LIVERDED'
			--AND ord_bookedby = 'DX'
			AND ord_bookdate > GETDATE()-10
			AND ord_status <> 'CMP' AND ord_status <> 'CAN'
			and ord_revtype3 = 'LIVERPOOL'
			AND ord_Tractor not like '*%'
			and len(ord_tractor)>1)

	-- Stops
		UPDATE stops SET stp_lgh_status='CMP', stp_departure_status='DNE', stp_status='DNE' WHERE ord_hdrnumber in
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'LIVERDED'
			--AND ord_bookedby = 'DX'
			AND ord_bookdate > GETDATE()-10
			and ord_revtype3 = 'HED'
			AND ord_status <> 'CMP' AND ord_status <> 'CAN'
			AND ord_Tractor not like '*%'
			and len(ord_tractor)>1
			)

	-- Assetassgnment
		UPDATE assetassignment SET asgn_status='CMP' WHERE mov_number in 
			(SELECT mov_number
			FROM orderheader
			WHERE ord_billto = 'LIVERDED'
			--AND ord_bookedby = 'DX'
			and ord_revtype3 = 'HED'
			AND ord_bookdate > GETDATE()-10
			AND ord_status <> 'CMP' AND ord_status <> 'CAN'
			AND ord_Tractor not like '*%'
			and len(ord_tractor)>1
			)

	-- Orderheader
		UPDATE orderheader SET ord_status='CMP', ord_invoicestatus='AVL' WHERE ord_hdrnumber in 
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'LIVERDED'
			--AND ord_bookedby = 'DX'
			AND ord_bookdate > GETDATE()-10
			and ord_revtype3 = 'HED'
			AND ord_status <> 'CMP'
			AND ord_status <> 'CAN'
			AND ord_Tractor not like '*%'
			and len(ord_tractor)>1
			)
	END
END



--select * from labelfile where labeldefinition = 'revtype3'
GO
