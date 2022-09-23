SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_ReciclaAnticipos_JR] @tollfilter char(1), @number int AS 
/*
INPUT PARMS:

tollfilter:  This input parm determines what to look the tolls up by
Valid values:  
1) 'O'      Order
2) 'L'      Trip Segment

@number:		key to lookup
*/

Declare @Operadores table(
		ID_operador varchar(8),
		ORD_numero  Integer,
		MOV_numero  Integer,
		LGH_numero  Integer)

declare	@V_ID_operador   varchar(8), 
		@V_ORD_numero	Integer, 
		@V_MOV_numero	Integer, 
		@V_LGH_numero	Integer

--Lookup by order for invoicing

if @tollfilter = 'L' and @number > 0
begin
	insert into @Operadores (ID_operador, ORD_numero, MOV_numero, LGH_numero)
				select lgh_driver1, ord_hdrnumber, mov_number,lgh_number from legheader where lgh_number = @number

end

--Lookup by leg for settlements
else if @tollfilter = 'O' and @number > 0
begin
		insert into @Operadores (ID_operador, ORD_numero, MOV_numero, LGH_numero)
		select lgh_driver1, ord_hdrnumber, mov_number,lgh_number from legheader where ord_hdrnumber = @number
end


--ID_operador, ORD_numero, MOV_numero, LGH_numero
--Recorre cada uno de los renglones de los Operadores

If Exists ( Select count(*) From  @Operadores )
	BEGIN -- 1 inicio del barrido de los operadores...
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE operadores_Cursor CURSOR FOR 
		SELECT ID_operador, ORD_numero, MOV_numero, LGH_numero
		FROM @Operadores 
	
		OPEN operadores_Cursor 
		FETCH NEXT FROM operadores_Cursor INTO @V_ID_operador, @V_ORD_numero, @V_MOV_numero, @V_LGH_numero
		WHILE @@FETCH_STATUS = 0 
		BEGIN --2 del cursor operadores_Cursor --2

			--SELECT @V_ID_operador, @V_ORD_numero, @V_MOV_numero, @V_LGH_numero

			-- Hace el update de los anticipos del operadore con los nuevos datos.
				Update paydetail 
				set ord_hdrnumber = @V_ORD_numero, lgh_number = @V_LGH_numero, mov_number = @V_MOV_numero, pyd_branch = 'Rec: '+convert(varchar(6),paydetail.ord_hdrnumber)
				from  orderheader O
				where pyd_status = 'HLD' 
				and not paydetail.pyd_remarks is null and 
				paydetail.ord_hdrnumber = O.ord_hdrnumber and
				O.ord_status = 'CAN' and
				paydetail.asgn_id = @V_ID_operador

	


			FETCH NEXT FROM operadores_Cursor INTO @V_ID_operador, @V_ORD_numero, @V_MOV_numero, @V_LGH_numero
		
		END --2

	CLOSE operadores_Cursor 
	DEALLOCATE operadores_Cursor 

END --1

--END







GO
