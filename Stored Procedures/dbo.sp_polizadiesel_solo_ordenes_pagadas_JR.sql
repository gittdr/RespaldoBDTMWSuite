SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para liberar a la poliza de diesel playdetail que no estan en ordenes pagadas...

--DROP PROCEDURE sp_polizadiesel_solo_ordenes_pagadas_JR
--GO

--exec sp_polizadiesel_solo_ordenes_pagadas_JR 69659

CREATE  PROCEDURE [dbo].[sp_polizadiesel_solo_ordenes_pagadas_JR] @ai_poliza integer
AS
DECLARE	
	@V_orden		Integer,
	@V_Peso			Integer,
	@V_StopDRP		Integer,
	@V_StopPUP		Integer


SET NOCOUNT ON

BEGIN --1 Principal

		-- Valida que el numero de la poliza tecleada sea de PROVEEDO y que no este transferida...
		IF (select count(*) from payheader where pyh_pyhnumber = @ai_poliza and pyh_paystatus = 'REL' and asgn_id = 'PROVEEDO') > 0 
				BEGIN --2

					-- Actualiza el detalle de la poliza quitando los paydetail de ordenes no completadas y pagadas...
					Update paydetail
					set pyd_status = 'HLD', pyh_number = 0
					from  orderheader OH
					where paydetail.pyh_number = @ai_poliza and paydetail.asgn_id = 'PROVEEDO' and paydetail.ord_hdrnumber > 0 and paydetail.ord_hdrnumber = OH.ord_hdrnumber 
					and ( select count(*) from assetassignment where mov_number = paydetail.mov_number and pyd_status = 'PPD') = 0

					-- Cuadra los montos de la poliza de diesel
					Update  payheader set pyh_totalcomp = (select sum(pyd_amount) from paydetail where pyh_number = @ai_poliza and pyd_pretax = 'Y'),		 pyh_totaldeduct = 0 where pyh_pyhnumber in (@ai_poliza)

					Update  payheader set pyh_totalreimbrs = (select sum(pyd_amount) from paydetail where  pyh_number = @ai_poliza and pyd_pretax = 'N')	where pyh_pyhnumber in (@ai_poliza)	

				
				Begin
					select  'La liquidacion '+cast(@ai_poliza as varchar(6)) +', Fue Procesada'
				END
				END -- 2
		ELSE
					select  'La liquidacion '+cast(@ai_poliza as varchar(6)) +', no procede'

		
		END -- 1 Ppal
		
GO
