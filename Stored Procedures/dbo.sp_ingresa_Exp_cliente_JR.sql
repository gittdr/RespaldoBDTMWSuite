SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para ingresar una Expiration al cliente con tarifa vencida
-- se corre cada dia a las 23:00 


--  exec sp_ingresa_Exp_cliente_JR

Create PROCEDURE [dbo].[sp_ingresa_Exp_cliente_JR]

AS
DECLARE	
	@V_Billto			Varchar(15),
	@V_NoTarifa			Integer,
	@s_observaciones	Varchar(25)

	
DECLARE @TTBilltos TABLE(
		NoTarifa	Integer Not Null,
		IDBillto	Varchar(15) Not NULL)
		

SET NOCOUNT ON

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya de tarifas vencidas
INSERT Into @TTBilltos
	SELECT tariffheader.tar_number ,trk_billto 
	FROM   tariffkey (NOLOCK) JOIN tariffheader (NOLOCK) on tariffkey.tar_number = tariffheader.tar_number
	WHERE   DateDiff(day,GetDate(),trk_enddate) =  1
			AND trk_enddate >= GetDate()
	ORDER BY trk_billto ASC



		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE tarifas_Cursor CURSOR FOR 
		SELECT NoTarifa, IDBillto
		FROM @TTBilltos 
	
		OPEN tarifas_Cursor 
		FETCH NEXT FROM tarifas_Cursor INTO @V_NoTarifa, @V_Billto
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
	
	select @s_observaciones = 'No. Tarifa Vencida:'+ cast(@V_NoTarifa as varchar(9))

		 INSERT INTO  expiration ( exp_idtype, exp_id, exp_code,   exp_expirationdate,   exp_routeto,   
						   exp_completed, exp_priority,   exp_compldate,   exp_updateby,   exp_creatdate,   
						   exp_updateon,   exp_description,   exp_milestoexp,   exp_city,   mov_number,   
						   exp_control_avl_date,   skip_trigger )  
				  VALUES ( 'CMP', @V_Billto, 'TAR',   GetDate(),  @V_NoTarifa,   
						   'N',   1,   '2049-12-31 23:59:00.000', 'AdminJR',  GetDate(),   
						   GetDate(), @s_observaciones,   0,   0,    null,   
						   'N',   null )


					--  select   exp_idtype, exp_id, exp_code,   exp_expirationdate,   exp_routeto, exp_completed, exp_priority,   exp_compldate,   exp_updateby,   exp_creatdate, exp_updateon,   exp_description,   exp_milestoexp,   exp_city,   mov_number,  exp_control_avl_date,   skip_trigger from expiration where exp_code = 'TAR'
			


		FETCH NEXT FROM tarifas_Cursor INTO @V_NoTarifa, @V_Billto
		
	
	END --3 curso de los movimientos 

	CLOSE tarifas_Cursor 
	DEALLOCATE tarifas_Cursor 
	
END --1 Principal

GO
