SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- Procedimiento para leer los anticipos creados
-- en automatico y manualmente.
--DROP PROCEDURE sp_ObtieneanticiposenGral 
--GO

--exec sp_ObtieneanticiposenGral  '20161001', '20161027 23:59:59'

CREATE PROCEDURE [dbo].[sp_ObtieneanticiposenGral]  @fechaini datetime, @fechafin datetime
AS

DECLARE	
	@V_i					integer,
	@V_kmspormov			decimal(10,2),
	@V_Opepormov			Varchar(10),
	@V_unidadpormov			Varchar(10),
	@V_registros			Integer,
	@V_Mov				Integer,
	@V_Proyecto				Varchar(5),
	@V_NomProy				Varchar(20),
	@V_codigo				Varchar(6),
	@V_NomCode				Varchar(30)

DECLARE @TTAnticipos TABLE(
		TTA_Movimiento	Integer not NULL,
		TTA_Codigo		VARCHAR(6) NULL,
		TTA_Nomcodigo	VARCHAR(30) NULL,
		TTA_Descripcion	VARCHAR(75) NULL,
		TTA_Monto		Money NULL,
		TTA_Creado		VARCHAR(20) NULL,
		TTA_FechaCreado	DateTime NULL,
		TTA_operador	VARCHAR(10),
		TTA_Proyecto	VARCHAR(5),
		TTA_NomProy		VARCHAR(20),
		TTA_Usuario		VARCHAR(100))

SET NOCOUNT ON

BEGIN --1 Principal


-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTAnticipos 
	SELECT	mov_number, pyt_itemcode,'', pyd_description, pyd_grossamount, pyd_createdby, 
			pyd_createdon,'               ','               ','          ',
			IsNull(usr_fname,'')+' '+ IsNull(usr_lname,'') Usuario
	FROM paydetail, ttsusers 
	WHERE not pyd_remarks  is null  and 
pyd_createdon between  @fechaini and @fechafin  and 
usr_userid = pyd_createdby 
--			mov_number in (
				--select mov_number from orderheader where 
					 --ord_startdate between  @fechaini and @fechafin  and 
				    -- ord_startdate between  '20120920' and '20120920 23:59:59'  and 
					--Ord_status not in ('MST','CAN') ) and
		--usr_userid = pyd_createdby 
	


INSERT Into @TTAnticipos 
	SELECT	mov_number, pyt_itemcode,'', pyd_description, pyd_grossamount, pyd_createdby, 
			pyd_createdon,'               ','               ','          ',
			'TDDE'
	FROM paydetail
	WHERE pyt_itemcode = 'TDDE' 
	and pyd_createdon between  @fechaini and @fechafin  
	
	



--Se obtiene el total de registros de la tabla temporal
select @V_registros =  (Select count(*) From  @TTAnticipos)
--print @V_registros
--Se inicializa el contador en 1
select @V_i = 0

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTAnticipos )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TTA_Movimiento, TTA_Codigo
		FROM @TTAnticipos
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_Mov, @V_codigo
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
		BEGIN -- del cursor Unidades_Cursor --3
				
				--Envia el nombre del operador de los vales.
				select	@V_Opepormov = ord_driver1, 
						@V_Proyecto = ord_revtype3
				from orderheader 
				where mov_number = @V_Mov
				--where mov_number = 201792
				
				-- Obtiene el nombre del proyecto.
				select @V_NomProy = name 
				From labelfile 
				Where labeldefinition = 'RevType3'
				and abbr = @V_Proyecto

				-- Obtiene el nombre del codigo de pago.
				Select @V_NomCode = pyt_description 
				From  paytype 
				Where pyt_itemcode = @V_codigo

		-- Actualiza la tabla temporal....

				Update @TTAnticipos 
					Set	TTA_operador	= @V_Opepormov,
						TTA_Proyecto	= @V_Proyecto,
						TTA_NomProy		= @V_NomProy,
						TTA_NomCodigo	= @V_NomCode
				Where TTA_Movimiento = @V_Mov
		
			
				--Se aumenta el contador en 1.
				select @V_i = @V_i + 1

		FETCH NEXT FROM Posiciones_Cursor INTO @V_Mov, @V_codigo
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 

END -- 2 si hay movimientos del RC
--cast((1250.00/102.00) as decimal(12,2))
/*
select count(TTL_Movimiento) Total, Sum(TTL_VLitros) Litros, 
	Sum(TTL_Kms) Kilometros, TTL_Unidad
, 	Cast(((Sum(TTL_Kms)/Sum(TTL_VLitros))) as decimal(5,2)) Rend ,TTL_Proyecto, TTL_NomProy
from @TTMovs_Litros
Where TTL_Unidad <> ''
Group by TTL_Unidad, TTL_Proyecto, TTL_NomProy
Order by TTL_NomProy
*/

--TTA_Movimiento, TTA_Codigo, TTA_Descripcion, TTA_Monto, TTA_Creado, TTA_FechaCreado, TTA_operador, TTA_Proyecto, TTA_NomProy

select TTA_Movimiento, TTA_Codigo,TTA_NomCodigo, TTA_Descripcion, TTA_Monto, TTA_Creado, TTA_FechaCreado, TTA_operador, TTA_Proyecto, TTA_NomProy, TTA_Usuario
from @TTAnticipos
order by TTA_NomProy asc


END --1 Principal









GO
