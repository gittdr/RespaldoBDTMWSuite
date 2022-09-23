SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para obtener los datos de las invoices con estatus HLD del cliente a consultar

--DROP PROCEDURE sp_inserta_aguinaldo_opera_JR
--GO

--  exec sp_inserta_aguinaldo_opera_JR

CREATE PROCEDURE [dbo].[sp_inserta_aguinaldo_opera_JR]

AS
DECLARE	
	@V_consecutivo			Integer,
	@V_Operador		Varchar(10),
	@V_concepto	    Varchar(6),
	@V_Monto		Money,
	@V_descripcion  Varchar(50)

	
DECLARE @TTmontosaguinaldo TABLE(
		ID		Int not null,
		operador	Varchar(10) NULL,
		concepto	varchar(8)null,
		monto		money Null,
		descripcion varchar(50) null)
		

SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTmontosaguinaldo
select ID_consecutivo,ID_operador, ID_concepto,ID_Monto,ID_descripcion from tabla_paso_aguinaldo_JR ;


		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT ID, operador,concepto, monto, descripcion
		FROM @TTmontosaguinaldo 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_consecutivo,	@V_Operador, @V_concepto, @V_Monto, @V_descripcion
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
				
			--Hace el insert de los datos .
			INSERT INTO  standingdeduction 
			( std_number, sdm_itemcode, std_description, std_balance, std_startbalance, std_endbalance, std_deductionrate, std_reductionrate, std_status, 
				 std_issuedate, asgn_type, asgn_id, std_priority, std_lastdeddate, std_lastreddate, std_lastcompdate, std_lastcalcdate, std_lastdedqty, 
			  std_lastredqty, std_lastcompqty, std_lastcalcqty, std_refnumtype ) 
		  VALUES ( @V_consecutivo, @V_concepto, @V_descripcion, @V_Monto, @V_Monto, 0.0000, @V_Monto, @V_Monto, 'INI',
		   {ts '2014-12-04 00:00:00.000'}, 'DRV', @V_Operador, '1', {ts '2014-12-04 00:00:00.000'}, {ts '2014-12-04 00:00:00.000'}, 
		   {ts '2014-12-04 00:00:00.000'}, {ts '2014-12-04 00:00:00.000'}, 0.0000, 0.0000, 0.0000, 0.0000, 'UNK' )

			


		FETCH NEXT FROM Posiciones_Cursor INTO @V_consecutivo,	@V_Operador, @V_concepto, @V_Monto, @V_descripcion
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END --1 Principal


GO
