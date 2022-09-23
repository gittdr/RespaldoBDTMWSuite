SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name> Linda
-- Create date: <Create Date,,> 15/04/2020
-- Description:	<Description,,> Cierra todas las ordenes creadas por DX para el BillTo TDRQUERE, que son aquellos proveedores que facturan con Convoy 360° (car_type3 = CONV) 10 días.
								--Requesitos de facturación Convoy 360° (ord_billto= TDRQUERE, ord_revtype4 = CNV)  

-- Exec [dbo].[sp_CerrarOrdersFactConvoyDX] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_CerrarOrdersFactConvoyDX](@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	-- Legheader
		UPDATE legheader SET lgh_outstatus = 'CMP' WHERE ord_hdrnumber in 
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'TDRQUERE'
			AND ord_bookedby = 'ESTAT'
			AND ord_status <> 'CMP' 
			AND ord_status <> 'CAN'
			and ord_revtype4 = 'CNV'
			AND CAST (ord_refnum AS VARCHAR ) IN  
				(SELECT CAST (ISNULL (ord_refnum,'') AS varchar)
				FROM orderheader 
				WHERE ord_billto = 'SAE' 
				AND ord_revtype4 = 'FRM'
				AND ord_status <> 'CAN'
				AND ord_bookdate > GETDATE()-60))

	-- Stops
		UPDATE stops SET stp_lgh_status='CMP', stp_departure_status='DNE', stp_status='DNE' WHERE ord_hdrnumber in
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'TDRQUERE'
			AND ord_bookedby = 'ESTAT'
			AND ord_status <> 'CMP' 
			AND ord_status <> 'CAN'
			and ord_revtype4 = 'CNV'
			AND CAST (ord_refnum AS VARCHAR ) IN  
				(SELECT CAST (ISNULL (ord_refnum,'') AS varchar)
				FROM orderheader 
				WHERE ord_billto = 'SAE' 
				AND ord_revtype4 = 'FRM'
				AND ord_status <> 'CAN'
				AND ord_bookdate > GETDATE()-60))

	-- Assetassignment
		UPDATE assetassignment SET asgn_status='CMP' WHERE mov_number in 
			(SELECT mov_number
			FROM orderheader
			WHERE ord_billto = 'TDRQUERE'
			AND ord_bookedby = 'ESTAT'
			AND ord_status <> 'CMP' 
			AND ord_status <> 'CAN'
			and ord_revtype4 = 'CNV'
			AND CAST (ord_refnum AS VARCHAR ) IN  
				(SELECT CAST (ISNULL (ord_refnum,'') AS varchar)
				FROM orderheader 
				WHERE ord_billto = 'SAE' 
				AND ord_revtype4 = 'FRM'
				AND ord_status <> 'CAN'
				AND ord_bookdate > GETDATE()-60))

	-- Orderheader
		UPDATE orderheader SET ord_status='CMP', ord_invoicestatus='AVL' WHERE ord_hdrnumber in 
			(SELECT ord_hdrnumber
			FROM orderheader
			WHERE ord_billto = 'TDRQUERE'
			AND ord_bookedby = 'ESTAT'
			AND ord_status <> 'CMP' 
			AND ord_status <> 'CAN'
			and ord_revtype4 = 'CNV'
			AND CAST (ord_refnum AS VARCHAR ) IN  
				(SELECT CAST (ISNULL (ord_refnum,'') AS varchar)
				FROM orderheader 
				WHERE ord_billto = 'SAE' 
				AND ord_revtype4 = 'FRM'
				AND ord_status <> 'CAN'
				AND ord_bookdate > GETDATE()-60))
	END
END
GO
