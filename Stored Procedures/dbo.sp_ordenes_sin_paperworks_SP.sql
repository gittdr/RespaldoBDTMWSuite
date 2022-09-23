SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para saber que ordenes no tienen completos los paperworks
--DROP PROCEDURE sp_cambiaPeso_maestrasALTO_JR
--GO

--exec sp_ordenes_sin_paperworks_SP

CREATE  PROCEDURE [dbo].[sp_ordenes_sin_paperworks_SP] 
AS
DECLARE	
	@V_orden		Integer,
	@V_billto		varchar(8),
	@V_pwcte		Integer,
	@V_pworden		Integer

DECLARE @TTdatosOrden TABLE(
		TT_orden		Int Null,
		TT_Billto		varchar(8) Null,
		TT_pw_cte		int null,
		TT_pw_orden		int null)
		
SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información que haya en la de paso 
	INSERT Into @TTdatosOrden
	select ord_hdrnumber, ord_billto, 0, 0 
	From orderheader where ord_bookdate > '2015-01-01' and ord_status not in ('MAS','CAN')


	-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TT_orden, TT_Billto
		FROM @TTdatosOrden 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_billto
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor ordenes

		-- Obtengo los documentos por cte.
		select @V_pwcte		=	count(bdt_doctype) FROM  BillDoctypes WHERE (cmp_id = @V_billto) AND IsNull(bdt_inv_required,'Y') = 'Y'
		select @V_pworden	=	count(distinct(abbr)) FROM BillDoctypes, paperwork where  cmp_id = @V_billto and abbr = bdt_doctype and ord_hdrnumber = @V_orden  AND IsNull(bdt_inv_required,'Y') = 'Y' and lgh_number >0 and pw_received = 'Y'

		Update @TTdatosOrden set TT_pw_cte = @V_pwcte, TT_pw_orden = @V_pworden  where TT_orden = @V_orden  and TT_Billto =  @V_billto
		
		FETCH NEXT FROM Posiciones_Cursor INTO @V_orden, @V_billto

		END -- fin de la tabla tempo

		Select * from @TTdatosOrden where TT_pw_cte <> TT_pw_orden
	END
		
GO
