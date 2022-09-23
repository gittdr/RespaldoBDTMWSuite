SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para leer los movimientos que inserta QSP
-- y pasarlos a la tabla checkcall.
--DROP PROCEDURE sp_ValesVsKms 
--GO

--exec sp_ValesVsKmsmtto  '2012-12-07', '2012-12-13'

CREATE PROCEDURE [dbo].[sp_ValesVsKmsmtto]  @fechaini datetime, @fechafin datetime
AS

DECLARE	
	@V_i					integer,
	@V_kmspormov			decimal(10,2),
	@V_Opepormov			Varchar(10),
	@V_unidadpormov			Varchar(10),
	@V_registros			Integer,
	@VTTL_Mov				Integer,
	@V_Proyecto				Varchar(5),
	@V_NomProy				Varchar(20),
	@V_Flota				Varchar(20),
	@V_abbr					Varchar(20),
	@V_axles				integer,
	@V_motor				Varchar(20),
	@V_RendCargado			float,
	@V_RendVacio			float

DECLARE @TTMovs_Litros TABLE(
		TTL_Movimiento	Integer not null,
        TTL_Fecha       datetime,
		TTL_Vlitros		decimal(10,2) NULL,
		TTL_Vcancel		integer NULL,
		TTL_Vcomple		integer NULL,
		TTL_Kms			decimal (10,2) NULL,
		TTL_totalkms	decimal (10,2) NULL,
		TTL_operador    VARCHAR(50),
		TTL_unidad		VARCHAR(50),
		TTL_Proyecto	VARCHAR(5),
		TTL_NomProy		VARCHAR(20),
		TTL_Flota		VARCHAR(20),
		TTL_abbr		Varchar(20),
		TTL_axles		Integer,
		TTL_motor		varchar(20),
		TTL_RendCargado float,
		TTL_RendVacio	float)
		
SET NOCOUNT ON

--TTL_Movimiento, 		TTL_Vlitros,		TTL_Vcancel,		TTL_Vcomple,		TTL_Kms,
		--TTL_totalkms,		TTL_operador,		TTL_unidad


BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTMovs_Litros 
	SELECT mov_number,(select ord_startdate from orderheader where orderheader.mov_number = paydetail.mov_number)   ,sum(pyd_quantity) , 0 , 0 , 0 , 0,'               ','               ','','', '','','', '','', ''
	 FROM paydetail 
	WHERE	pyt_itemcode in ('VALECO', 'COMCOM', 'COMBUS','VALEEL') and 
			mov_number in (
				select mov_number from orderheader where 
					--ord_startdate between  '2012-09-04' and '2012-09-10'  and 
					ord_startdate between  @fechaini and @fechafin  and 
					Ord_status not in ('MST','CAN') )
	Group by mov_number




--Se obtiene el total de registros de la tabla temporal
select @V_registros =  (Select count(*) From  @TTMovs_Litros)
--print @V_registros
--Se inicializa el contador en 1
select @V_i = 1

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTMovs_Litros )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT TTL_Movimiento
		FROM @TTMovs_Litros 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @VTTL_Mov
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
		BEGIN -- del cursor Unidades_Cursor --3
		--SELECT @VTTL_Mov

		--Tomando el valor del movimiento se buscan los kilometros y el nombre del operador y unidad
				Select @V_kmspormov = sum(Isnull(stp_trip_mileage,0)) 
				From   stops 
				Where  mov_number = @VTTL_Mov

				--Envia el nombre del operador de los vales.
				select @V_Opepormov = ord_driver1, @V_unidadpormov = ord_tractor, 
						@V_Proyecto = ord_revtype3
				from orderheader 
				where mov_number = @VTTL_Mov
				
				-- Obtiene el nombre del proyecto.
				select @V_NomProy = name 
				From labelfile 
				Where labeldefinition = 'RevType3'
				and abbr = @V_Proyecto

				--Obtiene la flota del tractor, para poder agruparlos en el reporte de esta manera.
				select @V_Flota= (select 
				Case abbr when (select abbr='01')then 'ABIERTO'  when  (select abbr='08') then 'ABIERTO' else UPPER(name)  end as Flota2),				@V_abbr = abbr
				 --abbr,  trc_type4, trc_terminal, trc_type3
				from labelfile
				left outer join tractorprofile on trc_fleet = abbr
				 where labeldefinition = 'Fleet' and (trc_number is not NULL) and (name != 'UNKNOWN')
						and @V_unidadpormov = trc_number
				order by trc_number

				--Obtener el Rendimiento esperado tanto en vacio como en cargado de acuerdo al peso
				SELECT  @V_axles=fueleconomy.fec_num_axles, @V_motor= fcl_loadweight, @V_RendCargado =						fueleconomy.fec_mpg_loaded, @V_RendVacio=fueleconomy.fec_mpg_empty
--				fueleconomy.fec_region , fueleconomy.fec_engine , fueleconomy.fec_num_axles , 
--				fueleconomy.fec_min_weight , fueleconomy.fec_max_weight , fueleconomy.fec_mpg_loaded , 
--				fueleconomy.fec_mpg_empty, fcl_loadweight, mov_number, lgh_number     
				FROM fueleconomy      
				left outer join fuelticket_calclog on fec_engine = fcl_engine and fec_num_axles = fcl_axles
				WHERE 
				(fueleconomy.fec_region = @V_Proyecto ) 
				AND ( fcl_loadweight between fueleconomy.fec_min_weight and fueleconomy.fec_max_weight )
				and mov_number = @VTTL_Mov --and fcl_loadstatus = 'BT'

		-- Actualiza la tabla temporal....

				Update @TTMovs_Litros 
					Set	TTL_Kms			= @V_kmspormov,
						TTL_unidad		= @V_unidadpormov, 
						TTL_operador	= @V_Opepormov,
						TTL_Proyecto	= @V_Proyecto,
						TTL_NomProy		= @V_NomProy,
						TTL_Flota		= @V_Flota,
						TTL_abbr		= @V_abbr,
						TTL_axles		= @V_axles,
						TTL_motor		= @V_motor,
						TTL_RendCargado = @V_RendCargado,
						TTL_RendVacio	= @V_RendVacio
				Where TTL_Movimiento = @VTTL_Mov
		
			
				--Se aumenta el contador en 1.
				select @V_i = @V_i + 1

		FETCH NEXT FROM Posiciones_Cursor INTO @VTTL_Mov
	
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

select TTL_Movimiento,TTL_Fecha, TTL_VLitros as Litros, TTL_Kms as Kilometros, TTL_Unidad, TTL_Proyecto, TTL_NomProy, TTL_Flota, TTL_abbr, TTL_axles, TTL_motor, TTL_RendCargado, TTL_RendVacio
from @TTMovs_Litros
Where (TTL_Unidad <> '') and (TTL_Unidad <> 'UNKNOWN')
Order by  TTL_Unidad

END --1 Principal


--exec sp_executa_SPValesKms










GO
