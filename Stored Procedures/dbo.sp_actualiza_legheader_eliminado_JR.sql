SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para actualizar los paydetail con legheader eliminado.

--  exec sp_actualiza_legheader_eliminado_JR

CREATE PROCEDURE [dbo].[sp_actualiza_legheader_eliminado_JR]

AS
DECLARE	
	@Vi_paydetail	integer,
	@Vs_unidad		Varchar(6),
	@Vd_fecha		date,
	@Vi_orden		Integer,
	@Vi_movimiento	Integer,
	@Vi_legheader	Integer,
	@Vi_consecpaydetail Integer

	
	
DECLARE @TTPaydetailsAActualizar TABLE(
		Tpaydetail	integer not NULL,
		Tidunidad	Varchar(6) Null,
		Tfecha	Date null)
		

SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
		INSERT Into @TTPaydetailsAActualizar
		SELECT  dbo.paydetail.pyd_number,  left(dbo.paydetail.pyd_description,4) as unidad, cast(dbo.paydetail.pyd_createdon as date) as fechacreacion
		FROM    dbo.paydetail LEFT OUTER JOIN
                dbo.legheader ON dbo.paydetail.lgh_number = dbo.legheader.lgh_number
		WHERE   (dbo.legheader.lgh_number IS NULL) and (dbo.paydetail.pyh_number in (select pyh_pyhnumber from payheader where asgn_type = 'TPR' and pyh_paystatus = 'REL'))

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT Tpaydetail, Tidunidad, Tfecha
		FROM @TTPaydetailsAActualizar

		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @Vi_paydetail, @Vs_unidad, @Vd_fecha
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3

				--Busca el maximo legheader para asignarselo a este paydetail...
				select @Vi_legheader = IsNull(max(lgh_number),0) from legheader where lgh_tractor = @Vs_unidad and lgh_startdate <= @Vd_fecha
				IF @Vi_legheader > 0
					select @Vi_movimiento = mov_number, @Vi_orden = ord_hdrnumber from legheader where lgh_tractor = @Vs_unidad and lgh_number = @Vi_legheader
				ELSE
					begin
						select @Vi_movimiento	= 0
						select @Vi_orden		= 0
						select @Vi_legheader	= 675613
					end


			--Hace el update de los datos .
			Update paydetail set lgh_number = @Vi_legheader, mov_number = @Vi_movimiento, ord_hdrnumber = @Vi_orden where pyd_number = @Vi_paydetail;
								

		FETCH NEXT FROM Posiciones_Cursor INTO  @Vi_paydetail, @Vs_unidad, @Vd_fecha
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END --1 Principal


GO
