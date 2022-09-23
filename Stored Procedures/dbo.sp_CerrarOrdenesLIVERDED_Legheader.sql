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
create PROCEDURE [dbo].[sp_CerrarOrdenesLIVERDED_Legheader] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	

	-- Stops
		UPDATE stops SET stp_lgh_status='CMP', stp_departure_status='DNE', stp_status='DNE' WHERE ord_hdrnumber in
			(select ord_hdrnumber from legheader 
where ord_hdrnumber in (select ord_hdrnumber
from orderheader where ord_bookdate > '2020-11-20' and ord_billto = 'liverded' AND ord_status = 'CMP')
and lgh_outstatus <> 'CMP'
			)

	-- Assetassgnment
		UPDATE assetassignment SET asgn_status='CMP' WHERE mov_number in 
			(select mov_number from legheader 
where ord_hdrnumber in (select ord_hdrnumber
from orderheader where ord_bookdate > '2020-11-20' and ord_billto = 'liverded' AND ord_status = 'CMP')
and lgh_outstatus <> 'CMP'
			)
			-- Legheader
		UPDATE legheader SET lgh_outstatus = 'CMP' WHERE ord_hdrnumber in 
			(select ord_hdrnumber from legheader 
where ord_hdrnumber in (select ord_hdrnumber
from orderheader where ord_bookdate > '2020-11-20' and ord_billto = 'liverded' AND ord_status = 'CMP')
and lgh_outstatus <> 'CMP')

	
	END
END



--select * from labelfile where labeldefinition = 'revtype3'
GO
