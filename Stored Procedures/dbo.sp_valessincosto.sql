SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Store Procedure que obtiene la venta del dia
--Drop Proc  sp_valessincosto
--exec sp_valessincosto
CREATE procedure [dbo].[sp_valessincosto]
AS
Declare @preciodiesel Float
Declare @tablaid int
Declare @fecha datetime


-- Toma el valor del combustbile actual.

SELECT	@preciodiesel = averagefuelprice.afp_price
			FROM averagefuelprice     (nolock) 
			WHERE  averagefuelprice.afp_date = (SELECT	 max(averagefuelprice.afp_date)
			FROM averagefuelprice   (nolock)   
			WHERE ( averagefuelprice.afp_tableid = '4' ) 
			and afp_default = 'Y')


IF not @preciodiesel  is null 
	BEGIN
		-- Hace el Update de los vales del dia de hoy
		Update fuelticket set ftk_cost = ftk_liters * @preciodiesel where ftk_cost is null and ftk_liters > 0 

		-- tambien se actualiza el detalle de pagos
		update paydetail 
		set pyd_rate = @preciodiesel, pyd_amount = pyd_quantity * @preciodiesel
		where pyt_itemcode = 'VALECO'  and pyd_amount is null
			and pyd_quantity > 0

		update paydetail 
		set pyd_rate = @preciodiesel, pyd_amount = -(pyd_quantity * @preciodiesel)
		where pyt_itemcode = 'CANVAL'  
		and pyd_quantity > 0 and pyd_amount is null

	END



GO
