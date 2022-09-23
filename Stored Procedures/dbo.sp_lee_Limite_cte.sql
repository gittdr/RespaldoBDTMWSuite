SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los limites de credito de los clientes y pasarlos a la tabla de company.
--DROP PROCEDURE sp_lee_Limite_cte
--GO
--exec sp_lee_Limite_cte

CREATE  PROCEDURE [dbo].[sp_lee_Limite_cte]
AS

DECLARE	
	@V_idcliente		Varchar(15), 
	@V_Monto		Float

DECLARE @Cte_credito TABLE(
		CC_idcliente		Varchar(15) NULL,
		CC_Monto		Float null)
SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso @Cte_credito
INSERT Into @Cte_credito 
	SELECT 	cliente, monto_credito
	FROM  tmwdes..cte_limite_credito

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @Cte_credito )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE cliente_Cursor CURSOR FOR 
		SELECT CC_idcliente, CC_Monto
		FROM @Cte_credito 
	
		OPEN cliente_Cursor 
		FETCH NEXT FROM cliente_Cursor INTO @V_idcliente, @V_monto
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --3
		SELECT @V_idcliente, @V_monto



			-- Busca el ID del operador segun su unidad
	
				update tmwSuite..Company
				set cmp_creditlimit = @V_monto, 
				    cmp_creditavail = @V_monto  
				where 	cmp_id = @V_idcliente




		FETCH NEXT FROM cliente_Cursor INTO @V_idcliente, @V_monto
	

END
	CLOSE cliente_Cursor 
	DEALLOCATE cliente_Cursor 

END

END --1 Principal



GO
