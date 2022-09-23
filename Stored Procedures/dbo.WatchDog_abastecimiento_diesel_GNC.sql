SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--DROP PROCEDURE [WatchDog_abastecimiento_diesel_GNC]
--GO

--exec [WatchDog_abastecimiento_diesel_GNC]

CREATE  PROCEDURE [dbo].[WatchDog_abastecimiento_diesel_GNC]
(	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogValesDieselGNC',
	@WatchName varchar(255)='ValesElect',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

--Reserved/Mandatory WatchDog Variables

DECLARE	
	@V_registros	integer,
	@V_i			Integer,
	@V_consecutivo	Integer,	
	@V_Mov			Integer, 
	@V_proyecto		char(6),		
	@V_Peso			Integer, 
	@V_lghnnumber	Integer,
	@V_estatus		char(1),	
	@V_cantidad		float,
	@V_costo		float,
	@ai_litros_f	integer,
	@ld_rend_acumulado float,
	@V_descarga		varchar(60),
	@li_kmsoper		integer,
	@v_accion		integer

	--Creamos tabla temporal donde se escribiran los vales que se van a poner en el perro
	
	DECLARE @TTmovsaabastecer TABLE(
		TT_noorden			Integer null,
		TT_nomovimiento		Integer null,
		TT_proyecto			char(6) NULL,
		TT_peso				Integer NULL,
		TT_litrosdiesel		Integer Null,
		TT_kms				Integer null,
		TT_accion			Integer Null,
		TT_Operador			Char(10) Null,
		TT_unidad			Char(10) null,
		TT_cmpini			Char(12) null,
		TT_cmpfin			Char(12) null,
		TT_status			Char(6) null,
		TT_fecha			datetime null,
		TT_lghnumber		integer null,
		TT_cliente			char(8) null,
		TT_rendimiento		float null,
		TT_Descarga			char(60) null
		)

BEGIN --1 Principal
-- Inserta en la tabla temporal la información de los insumos para capas
INSERT Into @TTmovsaabastecer 
	SELECT  lgh.ord_hdrnumber,   		lgh.mov_number,		lgh.lgh_class3,		lgh.lgh_tot_weight,			0 ,		
			kms = lgh.lgh_miles,  		0 ,			lgh.lgh_driver1 ,		lgh.lgh_tractor ,	lgh.cmp_id_start , 
			lgh.cmp_id_end ,		lgh.lgh_outstatus , lgh.lgh_startdate ,	lgh.lgh_number,  orderheader.ord_billto ,
			0.00 ,(select  top 1 cty_nmstct from stops, city where  stp_city = cty_code and mov_number = orderheader.mov_number and stp_event = 'LUL')
	FROM TMWSUITE..orderheader   orderheader, TMWSUITE.. legheader lgh
	WHERE	orderheader.ord_bookdate > '08-10-2015' and
			orderheader.ord_status not in ('AVL', 'CAN') and
			( orderheader.ord_revtype3 = 'P&G' )     and
			orderheader.ord_hdrnumber = lgh.ord_hdrnumber and
			lgh.lgh_miles > 0 and
			(select count(*) from TMWSUITE..fuelticket where mov_number = orderheader.mov_number and ftk_canceled_on is null  and ftk_created_by <> 'ANNTDR' ) = 0 
				and lgh.lgh_tractor <> 'UNKNOWN' and lgh.lgh_driver1  <> 'UNKNOWN'
				and orderheader.ord_extrainfo15 is null
				--and lgh.lgh_tractor in (select trc_number from TMWSUITE..tractorprofile where trc_commethod = 'CP3')
	order by lgh.ord_hdrnumber


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTmovsaabastecer )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE abastecer_Cursor CURSOR FOR 
		SELECT TT_nomovimiento,	TT_proyecto, TT_peso, TT_lghnumber,TT_descarga
		FROM @TTmovsaabastecer 
	
		OPEN abastecer_Cursor 
		FETCH NEXT FROM abastecer_Cursor INTO @V_Mov, @V_proyecto, @V_Peso, @V_lghnnumber, @V_descarga

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor abastecer_Cursor --3
				
			exec sp_obtiene_litros_diesel_jr @V_Mov, @V_proyecto,@V_Peso,@V_lghnnumber,@V_descarga, @ai_litros_f output, @ld_rend_acumulado output, @li_kmsoper output
			IF @ai_litros_f > 0 
				begin
				select @v_accion  = 1
				end 
			IF @ai_litros_f = 0 
				begin
				select @v_accion  = 0
				end 

			update @TTmovsaabastecer set TT_litrosdiesel = @ai_litros_f, TT_rendimiento = @ld_rend_acumulado ,TT_kms = @li_kmsoper, TT_accion = @v_accion
			where TT_nomovimiento = @V_Mov and TT_lghnumber = @V_lghnnumber

			FETCH NEXT FROM abastecer_Cursor INTO @V_Mov, @V_proyecto, @V_Peso, @V_lghnnumber, @V_descarga

		END --3 cursor del abastecer_Cursor
	CLOSE abastecer_Cursor 
	DEALLOCATE abastecer_Cursor 
END -- 2 si hay movimientos del RC
-- Marca los movimientos (tabla orderheader) en el campo ord_extrainfo15 con el dato de 'ENVIADA'
Update TMWSUITE..orderheader set ord_extrainfo15 = 'ENVIADA GNC' where mov_number in (Select TT_nomovimiento from @TTmovsaabastecer where TT_accion = 1)

-- Inserta los movimientos a la tabla de log.

Insert INTO order_header_log_vales_GNC(orden_log,movimiento_log,proyecto_log,peso_log,kms_log,litros_log,operador_log,unidad_log,rendimiento_log,ruta_log,fecha_log)
Select TT_noorden, TT_nomovimiento, TT_proyecto, TT_peso, TT_kms, TT_litrosdiesel,TT_Operador, TT_unidad, TT_rendimiento, TT_Descarga, getdate() from @TTmovsaabastecer where TT_accion = 1;

-----SELECT FINAL YA PROCESADO----------------------------------------------------------------------------------------------------------------------------------------------------------
-- se escribe ahora si ya formalmente en la salida para el perro


select 
	TT_unidad			as unidad,
	TT_Operador			as operador,
	TT_noorden			as orden,
	'GNC'			as proyecto,
	TT_fecha			as Fecha,
	TT_Descarga			as ruta,
	TT_rendimiento		as rendimiento,	
	TT_litrosdiesel		as litros

into #TempResults
 from 
@TTmovsaabastecer where TT_accion = 1

---RENDER DE DATOS PARA EL REPORTE-----------------------------------------------------------------------------------------------------------------------------------------------


	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
		Begin
			Set @SQL = 'Select * from #TempResults'
		End
	Else
		Begin
			Set @COLSQL = ''
			Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
			Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'

		End

	Exec (@SQL)
	Set NoCount Off




END --1 Principal
GO
