SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para obtener las ordenes que se generan contra las ordenes timbradas


--  exec [sp_generadas_timbradas_JR]

CREATE PROCEDURE [dbo].[sp_generadas_timbradas_JR]

AS
DECLARE	
	@V_billto	  Varchar(10),
	@Vi_sem		  Integer,
	@Vi_mes		  Integer,
	@Vi_anio	  Integer,
	@Vi_timbradas Integer,
	@Vi_generadas Integer,
	@Vi_automaticas Integer
	
DECLARE @TTordenestotales TABLE(
		Tot_billto	Varchar(10) not NULL,
		Tot_semana integer not null,
		Tot_mes integer not Null,
		Tot_anio integer not null,
		Tot_Generadas integer NULL,
		Tot_Timbradas integer Null,
		Tot_Automaticas integer Null)
		

DECLARE @TTordenestimbradas TABLE(
		Tb_billto	Varchar(10) not NULL,
		Tb_semana integer not Null,
		Tb_mes integer not Null,
		Tb_anio integer not null,
		Tb_Timbradas integer Null)


DECLARE @TTordenesautomaticas TABLE(
		Ta_billto	Varchar(10) not NULL,
		Ta_semana integer not Null,
		Ta_mes integer not Null,
		Ta_anio integer not null,
		Ta_automaticas integer Null)

SET NOCOUNT ON

BEGIN --1 Principal

--inserta en la tabla temporal de las ordenes timbradas.
		INSERT Into @TTordenestimbradas
		select oh.ord_billto, datepart(wk,Fecha), datepart(MM,Fecha),datepart(YYYY,Fecha),count(folio)
		from vista_carta_porte, orderheader oh, legheader lh
		where serie = 'TDRXP' and lh.lgh_number = Folio and oh.ord_hdrnumber = lh.ord_hdrnumber
		and datepart(YYYY,Fecha) = 2022 and datepart(MM,Fecha)>5 
		group by  datepart(wk,Fecha),datepart(MM,Fecha), datepart(YYYY,Fecha),oh.ord_billto
		order by 2,3,4,1

		-- inserta en la tabla temporal las ordenes timbradas en automatico
		INSERT Into @TTordenesautomaticas
		select billto , datepart(wk,Fecha),datepart(MM,fecha) , datepart(YYYY,fecha), count(distinct(segmento))
		from segmentosportimbrar_JR where datepart(YYYY,fecha) = 2022 and datepart(MM,fecha)>5 and estatus = 2
		group by datepart(wk,Fecha),datepart(mm,fecha),  datepart(YYYY,fecha), billto
		order by 2,3,4,1


	-- Inserta en la tabla temporal la información de las ordenes generadas
		INSERT Into @TTordenestotales
		select ord_billto , datepart(wk,ord_bookdate), datepart(MM,ord_bookdate) , datepart(YYYY,ord_bookdate), count(ord_hdrnumber),0,0
		from orderheader where datepart(YYYY,ord_bookdate) = 2022 and datepart(MM,ord_bookdate)>5 and ord_status <> 'CAN'
		group by datepart(wk,ord_bookdate),datepart(mm,ord_bookdate),  datepart(YYYY,ord_bookdate), ord_billto
		order by 2,3,1

		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT Tot_billto,Tot_semana, Tot_mes, Tot_anio
		FROM @TTordenestotales 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_billto, @vi_sem,@Vi_mes,	@Vi_anio
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
		set @Vi_timbradas = 0
		Set @Vi_automaticas = 0

		IF  @V_billto = 'PEÑATECA'
		BEGIN
		SELECT @V_billto = 'PEÑAFIEL'
		END

		--Busca el dato en la tabla de las timbradas.
		select @Vi_timbradas = isnull(Tb_Timbradas,0) from @TTordenestimbradas where Tb_billto = @V_billto and Tb_semana = @Vi_sem and Tb_mes = @Vi_mes and Tb_anio = @Vi_anio

		--Busca el dato en la tabla de las timbradas.
		select @Vi_automaticas = isnull(Ta_automaticas,0) from @TTordenesautomaticas where Ta_billto = @V_billto and Ta_semana = @Vi_sem and Ta_mes = @Vi_mes and Ta_anio = @Vi_anio
			
			-- update a la tabla de totales
			if @Vi_timbradas > 0
			Update @TTordenestotales set Tot_Timbradas = @Vi_timbradas
			where Tot_billto = @V_billto and Tot_semana = @Vi_sem and Tot_mes = @Vi_mes and	Tot_anio = @Vi_anio

			if @Vi_automaticas > 0
			Update @TTordenestotales set Tot_Automaticas =  @Vi_automaticas
			where Tot_billto = @V_billto and Tot_semana = @Vi_sem and Tot_mes = @Vi_mes and	Tot_anio = @Vi_anio
			
		

		FETCH NEXT FROM Posiciones_Cursor INTO  @V_billto ,@Vi_sem ,@Vi_mes,	@Vi_anio
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 

	select * from @TTordenestotales order by 2,3,1

END --1 Principal
GO
