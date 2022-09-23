SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--- Proceso para Obtener el movimiento actual de la unidad


CREATE PROCEDURE [dbo].[sp_obtiene_movimiento_jr]
(
	@P_unidad		varchar(10),
	@P_status1		varchar(4),
	@P_status2		varchar(4),
	@P_Movimiento	Int Out,
	@V_Ordennumber	Varchar(12) Out
)
AS

BEGIN 

DECLARE @V_mov_minimo int

-- reviso primero el movimiento que esta empezado...

		SELECT  @P_Movimiento = IsNull(Min(mov_number),0)  
		FROM	legheader 
		WHERE 	Mov_number	= (select  top 1 IsNull(mov_number,0)
		FROM    legheader 
		WHERE   lgh_tractor	=  @P_unidad
				and lgh_outstatus  in ('STD')
		order by lgh_startdate )

		IF @P_Movimiento = 0
		Begin

			SELECT  @P_Movimiento = IsNull(Min(mov_number),0)  
			FROM	legheader 
			WHERE 	Mov_number	= (select  top 1 IsNull(mov_number,0)
			FROM    legheader 
			WHERE   lgh_tractor	=  @P_unidad
					and lgh_outstatus not in (@P_status1, @P_status2 )
			order by lgh_startdate )
		END

		IF @P_Movimiento > 0
			BEGIN
				select @V_Ordennumber = IsNull(Min(ord_number),'0') 
				from Orderheader 
				where mov_number = @P_Movimiento 
			END
		RETURN 0
		END

GO
