SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************

SP envia CABECERAS DE CARGA

AUTOR: EMOLVERA
VERSION: 1.0
FECHA: 1 de septiembre 2016 2:57pm

*********prueba envio cabecera de carga********************
exec sp_enviaMacroCab_de_carga   449158, 501, 'PLN'
***********************************************************
QUERYS adicionales de prueba


select mov_number from orderheader where ord_Hdrnumber = 419000

select lgh_number from legheader where mov_number = (select mov_number from orderheader where ord_hdrnumber =  '415729')
select ord_status from orderheader where ord_hdrnumber =  '290035'
update orderheader set ord_status ='PLN' where ord_hdrnumber =  '415729'
update legheader set lgh_out_status ='PLN' and lgh_number in =

select * from stops where lgh_number = '474820'
***************************************************************************************************************************/

CREATE  PROCEDURE [dbo].[sp_enviaMacroCab_de_carga]  @NoMovimiento integer, @unidad VARCHAR(8),	@statusOrden	VARCHAR(8)
AS

--Declaramos las variables a usar dentro del cursor que recorrera los legs
declare @v_leg varchar(10),
        @v_unidad varchar(10)

--Declaramos una tabla temporal para los legs que no esten completados y tegan una unidad asignada.
DECLARE @TTlegs TABLE(
		TT_leg		Varchar(500) NULL,
		TT_unidad varchar(10)
		)

BEGIN 

--Insertamos en la tabla temporal los legs  que tiene el movimiento enviado como parametro.
insert into @TTlegs

select lgh_number, lgh_tractor from legheader (nolock)
where mov_number = @NoMovimiento and lgh_tractor <> 'UNKNOWN' and lgh_outstatus <> 'CMP' -- and lgh_outstatus = 'PLN'

    --Si tenemos legs en la tabla temporal
		If Exists ( Select count(*) From  @TTlegs )
		 Begin--4 si hay legs
           -- Se declara un curso para ir leyendo la tabla de paso
           DECLARE lcursor CURSOR FOR 
		   SELECT TT_leg, TT_unidad FROM @TTlegs 
								
		   OPEN lcursor
		   FETCH NEXT FROM lcursor INTO @V_leg, @v_unidad
	       WHILE @@FETCH_STATUS = 0 
	        BEGIN --5 del cursor Leg_Cursor 
		        
				---coremos el sp que envia las cabeceras de carga por leg
				exec sp_enviaMacroCab_de_cargaleg  @v_leg,@v_unidad,'PLN'
				
			 CLOSE lcursor
		     DEALLOCATE lcursor
		    END -- 4 curso de los legs
		  End

END
GO
GRANT EXECUTE ON  [dbo].[sp_enviaMacroCab_de_carga] TO [public]
GO
