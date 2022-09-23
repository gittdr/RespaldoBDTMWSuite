SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer los movimientos de entrada y salida del Recurso Confiable
-- y pasarlos a la tabla checkcall.
--    DROP PROCEDURE sp_lee_movs_RC
--GO
--   exec sp_lee_movs_RC
--   select * from qsp..movimientos_RC

CREATE   PROCEDURE [dbo].[sp_lee_movs_RC]
AS

DECLARE	
	@V_fechamov		Datetime, 
	@V_latitud		float, 
	@V_longitud		float, 
	@Vpaso_latitud		varchar(30), 
	@Vpaso_longitud		varchar(30), 
	@V_RFCOper		Varchar(10), 
	@V_IDOPERA		varchar(10),
	@V_TIPOMOV		varchar(5),
	@V_ubicacion		Varchar(100),
	@V_Tractor		Varchar(10),
	@V_descMov		Varchar(35),
	@V_Folio		bigInt,
	@V_CONSECCKC		bigint,
	@li_tbl_SN			INT,
	@ls_nombreflota			Varchar(30),
	@ls_comentarioAct		Varchar(254),
	@li_inboxflota			INT,
	@li_defaultdriver		INT,
	@li_flota			INT,
	@lsContenido			Varchar(100),
	@lsSubject			Varchar(100),
	@liFolder 			INT,
	@lsDeliverTo			Varchar(10),
	@li_quehace			Int

DECLARE @TTMovs_RC TABLE(
		RC_Folio		bigint not null,
		RC_fecha		DateTime null,
		RC_latseconds		Varchar(30) null,
		RC_longseconds		Varchar(30) null,
		RC_RFCOper		Varchar(10) NULL,
		RC_tipomov		Varchar(5) NULL,
		RC_ubicacion		Varchar(100) NULL)

SET NOCOUNT ON

BEGIN --1 Principal

-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
INSERT Into @TTMovs_RC 
	SELECT 	MRC.id_folio,
		MRC.fecha_mov, 
		MRC.latitud, 
		MRC.longitud, 
		right(MRC.RFC_operador,10),
		MRC.tipo_mov, 
		MRC.ubicacion
	FROM  QSP..movimientos_RC MRC (NOLOCK) 
	Where MRC.idevento Is Null
	Order By 1


-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TTMovs_RC )
	BEGIN --3 Si hay movimientos de posiciones

		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT RC_Folio, RC_fecha, 	RC_latseconds, 	RC_longseconds, 	RC_RFCOper, 	RC_TIPOMOV, RC_ubicacion
		FROM @TTMovs_RC
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @V_Folio, @V_fechamov, @Vpaso_latitud, @Vpaso_longitud, @V_RFCOper, @V_TIPOMOV, @V_ubicacion
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Posiciones_Cursor --3
		SELECT @V_Folio, @V_fechamov, @Vpaso_latitud,	@Vpaso_longitud, @V_RFCOper, @V_TIPOMOV, @V_ubicacion

		--Valida que el numero economico no sea el numero de antena.
		IF not(@V_RFCOper) is null
			BEGIN	-- cuando el RFC no es null
				-- Busca el ID del operador segun su unidad

			IF Exists (SELECT mpp_id FROM tmwSuite..manpowerprofile WHERE mpp_misc3 = @V_RFCOper)
				BEGIN --Begin cuando si existe el RFC
					SELECT @V_IDOPERA = IsNull(mpp_id,'XXX'), @V_Tractor = IsNull(mpp_tractornumber,'XXX')
					FROM tmwSuite..manpowerprofile 
					WHERE mpp_misc3 = @V_RFCOper and  mpp_status <> 'OUT'
						
						-- Define si esta entrando o saliendo
						IF upper(@V_TIPOMOV) = 'RCENT'
						Begin
							Select @V_descMov = 'Reg Ent '
						End
						IF Upper(@V_TIPOMOV) = 'RCSAL'
						Begin
							Select @V_descMov = 'Reg Sal '
						End
				
						-- Multiplica por 3600 latitud y longitud
		--				IF Is(@V_latitud) null =
						Select @V_latitud	=	0
						Select @V_longitud	=	0

		

						SELECT @V_ubicacion 		= left((@V_descMov + @V_ubicacion),100)
				
						-- Lee el consecutivo de los checkcall para hacer el insert a la tabla.					
						execute @V_CONSECCKC = tmwSuite..getsystemnumber_gateway N'CKCNUM' , NULL , 1 
						-- Inserta el nuevo checkcall
						Insert tmwSuite..checkcall(
						ckc_number, ckc_status, ckc_asgntype, ckc_asgnid, ckc_date, ckc_event, ckc_city, ckc_comment, 
						ckc_updatedby, ckc_updatedon, ckc_latseconds, ckc_longseconds, ckc_lghnumber, ckc_tractor, ckc_extsensoralarm, ckc_vehicleignition, 
						ckc_milesfrom, ckc_directionfrom, ckc_validity, ckc_mtavailable, ckc_minutes, ckc_mileage, ckc_home, ckc_cityname, 
						ckc_state, ckc_zip, ckc_commentlarge, ckc_minutes_to_final, ckc_miles_to_final, ckc_Odometer, TripStatus, ckc_odometer2, 
						ckc_speed, ckc_speed2, ckc_heading, ckc_gps_type, ckc_gps_miles, ckc_fuel_meter, ckc_idle_meter)
						Values (@V_CONSECCKC, 'HIST', 		'DRV', 	@V_IDOPERA,	@V_fechamov, 	@V_TIPOMOV, 		0, 	@V_ubicacion, 
							'RC', 		GetDate(), 	@V_latitud,	@V_longitud, 		0, 		@V_Tractor, 	Null, 	Null, 
							1,		Null, 		Null, 	Null, 		0, 		0, 		Null, 	Null, 
							Null, 		Null, 		@V_ubicacion, 		0,		0,		0,		0,	0,		
							Null, 		Null, 		Null, 	Null, 		Null, 		Null, 		Null)				

/*
						-- Inserta el mensaje para que se vaya a TotalMail.
-------------------------------------------------- Codigo para inserta mensaje en TotalMail
					-- valida que existe el folder de la unidad

					IF Exists (SELECT Trucks.SN FROM tmwSuite..tblTrucks Trucks, tmwSuite..tblCabUnits Cab WHERE 	Trucks.Truckname = @V_Tractor  and Cab.SN = Trucks.DefaultCabUnit)
					Begin
						-- Toma la configuración de la Unidad
							SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
							@liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
							@li_flota = Trucks.CurrentDispatcher
							FROM tmwSuite..tblTrucks Trucks, tmwSuite..tblCabUnits Cab 
							WHERE 	Trucks.Truckname = @V_Tractor  and Cab.SN = Trucks.DefaultCabUnit
						
						-- Toma el nombre de la flota
							SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
							FROM tmwSuite..tblDispatchGroup flota 
							WHERE SN = @li_flota
													
										
							Select @lsSubject 	=  'R.C. '+@V_ubicacion


							Select @lsSubject	=  Left(@lsSubject,255)

							Select @lsContenido	=  @V_ubicacion
						
							-- Insert el mensaje en la carpeta de la unidad 
							INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
							Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
							Values(5, 1, 1, 4, 3, @V_fechamov, GetDate(), @liFolder, @lsContenido, @V_Tractor, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)
	
							-- Insert el mensaje en la carpeta general
						
							INSERT INTO tmwSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
							Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN )
							Values(4, 1, 1, 4, 3, @V_fechamov, GetDate(), @li_inboxflota, @lsContenido, @V_Tractor, @lsSubject , @ls_nombreflota , @li_tbl_SN, @li_defaultdriver)
							select @@identity

							Insert Into TMWSuite..tblMsgProperties ( MsgSN,PropSN,Value)
							values(@@identity, 6, 175519  )

						Update QSP..movimientos_RC
						Set idevento = 1
						Where  QSP..movimientos_RC.id_folio = @V_Folio;
							
						END 

------------------------------------ Codigo para inserta mensaje en TotalMail
*/

						Update QSP..movimientos_RC
						Set idevento = 2
						Where  QSP..movimientos_RC.id_folio = @V_Folio;

					END --cuando valida si existe el RFC del operador
				END -- cuando exise el RFC en el Driver		
		
				FETCH NEXT FROM Posiciones_Cursor INTO @V_Folio, @V_fechamov, @Vpaso_latitud, @Vpaso_longitud, @V_RFCOper, @V_TIPOMOV, @V_ubicacion
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END -- 2 si hay movimientos del RC
END --1 Principal
GO
