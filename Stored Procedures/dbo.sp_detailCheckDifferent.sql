SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--use tmwSuite
--exec sp_detailCheckDifferent '2012-02-01' ,'2012-02-16'
--DROP PROCEDURE sp_detailCheckDifferent

--Procedimiento para verificar los cheques otorgados por Anticipo a operadores
	-- Algoritmo: Obtener los cheques por periodo
	--Verificar los cheques en la tabla de banco_cheque_detalle por número de cheque
	--para ver los movimientos
	--Verificar que estos movimientos se encuentren en la tabla de tmwSuite..paydetail y verificar el monto.

CREATE PROCEDURE [dbo].[sp_detailCheckDifferent] (@V_fechaI datetime,
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
		@V_amount float,
		@V_idReference integer,
		@V_AmountReference Float,
		@V_AmountReferenceTmw Float,
		@V_orden int,
		@V_usuario varchar(10),
		@V_mov int,
		@V_operador varchar(100)
		
	SET NOCOUNT ON

BEGIN --Principal 1
	--Borrar los registros existentes en la tabla tmwSuite..Checks_SiltTmwSuite
	delete from tmwSuite..Checks_SiltTmwSuite
	delete from tmwSuite..detail_check
	--Validar la fecha de consulta 
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

				--Si el monto es diferente de 0, existe diferencia.
				if (@V_AmountSilt+@V_AmountTmw)!= 0
				begin
					--Si el numero de referencias es distinta en silt y tmw
					--if @V_#CheckSilt != @V_#CheckTmw
					--begin
						--Verificar cual es la referencia que ha sido borrada en tmw
						DECLARE cursor_referenciaSilt CURSOR FOR
						select referencia, monto_concepto from tdrsilt..banco_cheque_detalle where id_cheque = @V_idCheck
						OPEN cursor_referenciaSilt
						FETCH NEXT FROM cursor_referenciaSilt INTO @V_idReference,@V_AmountReference
						WHILE @@FETCH_STATUS = 0
						begin
							select @V_idReference, @V_AmountReference
							

							if not Exists (select * from tmwsuite..paydetail where pyd_number=@V_idReference)
							begin
								select @V_orden = (Select ord_hdrnumber from paydetailaudit where pyd_number in (@V_idReference) and not pyd_remarks is null and audit_status = 'D')
								select @V_usuario = (Select pyd_updatedby from paydetailaudit where pyd_number in (@V_idReference) and not pyd_remarks is null and audit_status = 'D')
								select @V_mov = (Select mov_number from paydetailaudit where pyd_number in (@V_idReference) and not pyd_remarks is null and audit_status = 'D')							
								select @V_operador = (Select asgn_id from paydetailaudit where pyd_number in (@V_idReference) and not pyd_remarks is null and audit_status = 'D')	
								insert into tmwSuite..detail_check values (@V_idCheck,@V_orden,@V_idReference,'Borrados',@V_usuario,@V_buildDate,@V_AmountReference,0,@V_mov,@V_operador)
								print 'Referencia '+ cast(@V_idReference as nvarchar(30))+ ' MontoSilt ' +  cast(@V_AmountReference as nvarchar(30))
							end
							else
							begin
								select @V_AmountReferenceTmw = (select pyd_amount from tmwsuite..paydetail where pyd_number=@V_idReference)
								if (@V_AmountReference + @V_AmountReferenceTmw)!= 0
								begin
								
									select @V_orden = (select ord_hdrnumber from tmwsuite..paydetail where pyd_number = @V_idReference )
									select @V_usuario = (select pyd_updatedby from tmwsuite..paydetail where pyd_number = @V_idReference)
									select @V_mov = (select mov_number from tmwsuite..paydetail where pyd_number = @V_idReference)
									select @V_operador = (select asgn_id from tmwsuite..paydetail where pyd_number = @V_idReference)
									insert into tmwSuite..detail_check values (@V_idCheck,@V_orden,@V_idReference,'Diferencia',@V_usuario,@V_buildDate,@V_AmountReference,@V_AmountReferenceTmw,@V_mov,@V_operador)
									--print 'Referencia '+ cast(@V_idReference as nvarchar(30))+ ' Cheque ' +  cast(@V_idCheck as nvarchar(30))+ ' Monto ' +  cast((@V_AmountReference + @V_AmountReferenceTmw) as nvarchar(30))
								end
							end

							FETCH NEXT FROM cursor_referenciaSilt INTO @V_idReference,@V_AmountReference
						end
						
						CLOSE cursor_referenciaSilt 
						DEALLOCATE cursor_referenciaSilt
					--end

					insert into tmwSuite..Checks_SiltTmwSuite values (@V_idCheck,@V_buildDate,@V_amount,@V_#CheckSilt,@V_AmountSilt,@V_#CheckTmw,@V_AmountTmw)
				end

				FETCH NEXT FROM Posiciones_Cursor INTO @V_idCheck,@V_buildDate,@V_amount
			END--Del cursor Posiciones_Cursor 3
			CLOSE Posiciones_Cursor 
			DEALLOCATE Posiciones_Cursor
		END --Si hay movimientos 2
	--END --Valida fecha de consulta
END --Principal 1
GO
