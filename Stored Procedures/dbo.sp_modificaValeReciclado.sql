SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--execute sp_modificaValeReciclado @user,@mov,@segmento,@ticket,@litros,
CREATE PROCEDURE [dbo].[sp_modificaValeReciclado] (
@usuario varchar (50) ,
@movimiento int,
@segmento int,
@ticket int,
@litros float
) as 

DECLARE @precio float,
	@monto float


select @precio = (SELECT top 1 averagefuelprice.afp_price FROM averagefuelprice WHERE ( averagefuelprice.afp_tableid = '4' ) order by afp_date desc)
select @monto = @precio * @litros


UPDATE fuelticket SET ftk_updated_by = @usuario, ftk_cost = @monto, mov_number = @movimiento,
            ftk_canceled_by = NULL, ftk_canceled_on = NULL, lgh_number = @segmento WHERE ftk_ticket_number = @ticket

return 0

GO
