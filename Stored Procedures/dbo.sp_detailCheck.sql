SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--use tmwSuite
--exec sp_detailCheck '2011-02-01' ,'2012-02-13'
--DROP PROCEDURE sp_detailCheck

--Procedimiento para verificar los cheques otorgados por Anticipo a operadores
	-- Algoritmo: Obtener los cheques por periodo
	--Verificar los cheques en la tabla de banco_cheque_detalle por número de cheque
	--para ver los movimientos
	--Verificar que estos movimientos se encuentren en la tabla de tmwSuite..paydetail y verificar el monto.

CREATE PROCEDURE [dbo].[sp_detailCheck] (@V_fechaI datetime,
		@V_fechaF datetime )
AS  
	--Instance Variables
	DECLARE
		@V_AmountSilt Float,
		@V_#CheckSilt integer,
		@V_AmountTmw Float,
		@V_#CheckTmw integer,
		@V_idCheck integer,
		@V_buildDate Datetime,
		@V_amount float
		
	SET NOCOUNT ON

BEGIN --Principal 1
	--Borrar los registros existentes en la tabla tmwSuite..Checks_SiltTmwSuite
	delete from tmwSuite..Checks_SiltTmwSuite
	
	--if (year(@V_fechaI)>= 2012 and year(@V_fechaF)>= 2012)
	--BEGIN --Valida fecha de consulta

		--Si hay movimientos en la tabla continua
		If Exists (select count(*) from tdrsilt..banco_cheque where f_elaboracion between @V_fechaI  and @V_fechaF )
		BEGIN --Si hay movimientos 2
			--Se declara un cursor para leer los cheques de cierto periodo
			DECLARE Posiciones_Cursor CURSOR FOR
			select id_cheque, f_elaboracion, monto_importe from tdrsilt..banco_cheque where id_config=4 and f_elaboracion between @V_fechaI  and @V_fechaF

			OPEN Posiciones_Cursor
			FETCH NEXT FROM Posiciones_Cursor INTO @V_idCheck,@V_buildDate,@V_amount
			WHILE @@FETCH_STATUS = 0
			BEGIN --Del cursor Posiciones_Cursor 3
				select @V_idCheck 
				print 'Cheque:  '+ cast(@V_idCheck as nvarchar(30))
				select @V_#CheckSilt = (select count(referencia) from tdrsilt..banco_cheque_detalle where id_cheque = @V_idCheck)
				print '#Silt ' + cast(@V_#CheckSilt as nvarchar(30))

				select @V_#CheckTmw = (select count(pyd_amount)from tmwsuite..paydetail where pyd_number in (
				select referencia from tdrsilt..banco_cheque_detalle where id_cheque = @V_idCheck))
				print  '# tmw: '+ cast(@V_#CheckTmw as nvarchar(30))

				select @V_AmountSilt = (select sum(monto_concepto) from tdrsilt..banco_cheque_detalle where id_cheque = @V_idCheck)
				print 'Monto Silt '+ cast(@V_AmountSilt as nvarchar(30))

				select @V_AmountTmw = (select sum(pyd_amount)from tmwsuite..paydetail where pyd_number in (
				select referencia from tdrsilt..banco_cheque_detalle where id_cheque = @V_idCheck))
				print 'Monto tmw: '+ cast(@V_AmountTmw as nvarchar(30))
				
				select @V_buildDate
				print 'Fecha '+ cast(@V_buildDate as nvarchar(30))


				if (@V_AmountSilt+@V_AmountTmw)!=0
				begin
					insert into tmwSuite..Checks_SiltTmwSuite values (@V_idCheck,@V_buildDate,@V_amount,@V_#CheckSilt,@V_AmountSilt,@V_#CheckTmw,@V_AmountTmw)
				end

				FETCH NEXT FROM Posiciones_Cursor INTO @V_idCheck,@V_buildDate,@V_amount
			END--Del cursor Posiciones_Cursor 3
			CLOSE Posiciones_Cursor 
			DEALLOCATE Posiciones_Cursor
			
		END --Si hay movimientos 2
	--END --Valida fechas de consulta
END --Principal 1
GO
