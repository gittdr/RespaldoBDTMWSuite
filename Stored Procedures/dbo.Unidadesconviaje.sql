SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DROP PROCEDURE Unidadesconviaje
--GO
-- Cuando la unidad no tiene tmc marca error.


CREATE   PROCEDURE [dbo].[Unidadesconviaje]
	@hoursback 				INT,
	@hoursout 				INT
AS

DECLARE		
	@hoursbackdate			DATETIME,
	@hoursoutdate			DATETIME,
	@liFolder 			INT, 
	@unidad				varchar(8),
	@pos_act			INT,
	@pos_ant			INT,
	@Fecha_pos_act			DateTime,
	@Fecha_pos_ant			DateTime,
	@lsDeliverTo			Varchar(10),
	@as_operador			Varchar(10),
	@li_count			INT,
	@lsContenido			Varchar(100),
	@lsSubject			Varchar(100),
	@ls_UnidadUDA			Varchar(6),
	@ls_ignitionAct			Varchar(2),
	@ls_ignitionAnt			Varchar(2),
	@li_minutos			INT,
	@ls_comentarioAct		Varchar(254),
	@ls_comentarioAnt		Varchar(254),
	@li_yaenvioaleta		INT,
	@li_legheader			INT,
	@li_numstop			INT,
	@ls_stp_event			Varchar(6),
	@ls_cty_nmstct			Varchar(30),
	@ld_stp_arrivaldate		DateTime,
	@ld_stp_departuredate		DateTime,
	@li_noorden			INT,
	@li_tbl_SN			INT,
	@li_defaultdriver		INT,
	@li_flota			INT,
	@li_inboxflota			INT,
	@ls_nombreflota			Varchar(30),
	@ls_skip_eta			Varchar(1),
	@ls_billto			varchar(8),
	@ls_nombreoper			varchar(45),
	@idmensaje 			INT,
	@li_nivel1 			INT,
	@li_tiempo1 			INT,
	@ls_ce_nivel1 			varchar(100),
	@ls_ce_ccp_nivel1 		varchar(100),
	@li_nivel2 			INT,
	@li_tiempo2 			INT,
	@ls_ce_nivel2 			varchar(100),
	@ls_ce_ccp_nivel2 		varchar(100),
	@li_nivel3 			INT,
	@li_tiempo3 			INT,
	@ls_ce_nivel3 			varchar(100),
	@ls_ce_ccp_nivel3 		varchar(100),
	@li_correo1			Int,
	@li_correocopia1		Int,
	@li_correo2			Int,
	@li_correocopia2		Int,
	@li_correo3			Int,
	@li_correocopia3		Int


DECLARE @TTAlertas TABLE(
	ord_hdrnumber 			INT 		NULL,
	legheader			INT		NULL,
	evt_tractor			varchar(8)	NULL,
	trc_driver			varchar(8) 	NULL,
	trc_gps_desc			VARCHAR(255)    NULL,
	trc_gps_date			DATETIME 	NULL,
	trc_gps_desc_ant		VARCHAR(255)    NULL,
	trc_gps_date_ant		DATETIME 	NULL,
	skip_eta			Varchar(1)	NULL,
	no_posicion_ant			INT		NULL,
	ord_billto			varchar(8)	NULL,
	mpp_lastfirst			varchar(45)	NULL)

IF @hoursback = 0
	SELECT @hoursback= 1000000
IF @hoursout = 0
	SELECT @hoursout = 1000000

-- Get the hoursback and  hoursout into variables
SELECT @hoursbackdate = DATEADD(hour, -@hoursback, GETDATE())
SELECT @hoursoutdate  = DATEADD(hour,  @hoursout, GETDATE())

Select @li_yaenvioaleta = 0
select @li_count = 1

	 

-- Obtengo los datos de los correos de ETA TDR
SELECT  @li_nivel1  	  = IsNull(nivel1,0), 
	@li_tiempo1 	  = IsNull(tiempo1,0), 
	@ls_ce_nivel1	  = IsNull(ce_nivel1,'N'), 
	@ls_ce_ccp_nivel1 = IsNull(ce_ccp_nivel1,'N'),
	@li_nivel2	  = IsNull(nivel2,0), 
	@li_tiempo2	  = IsNull(tiempo2,0), 
	@ls_ce_nivel2     = IsNull(ce_nivel2,'N'), 
	@ls_ce_ccp_nivel2 = IsNull(ce_ccp_nivel2,'N'),
	@li_nivel3	  = IsNull(nivel3,0), 
	@li_tiempo3	  = IsNull(tiempo3,0), 
	@ls_ce_nivel3	  = IsNull(ce_nivel3,'N'), 
	@ls_ce_ccp_nivel3 = IsNull(ce_ccp_nivel3,'N')
FROM tdr..eta_tdr 
WHERE id_modulo = 1

IF @li_count > 0
BEGIN --Begin Principal --1
	INSERT INTO	@TTAlertas 
	SELECT	legheader.ord_hdrnumber,
	legheader.lgh_number,
	legheader.lgh_tractor,
	trc_driver,
	trc_gps_desc,
	getdate(),
	'Desc',
	getdate(),
	IsNull(trc_eta_skip,'N'),
	0,
	legheader.ord_billto,
	m.mpp_lastfirst
	FROM	legheader_active legheader 
	inner join company company_a 	on legheader.cmp_id_start 	 = company_a.cmp_id
	inner join company company_b	on legheader.cmp_id_end 	 = company_b.cmp_id
	left  join orderheader 		on legheader.ord_hdrnumber 	 = orderheader.ord_hdrnumber
	inner join manpowerprofile m 	on legheader.lgh_driver1 	 = m.mpp_id
	inner join tractorprofile trcp 	on legheader.lgh_tractor 	 = trcp.trc_number
	inner join trailerprofile trlp 	on legheader.lgh_primary_trailer = trlp.trl_id
	WHERE	
	lgh_enddate   >=  @hoursbackdate AND	
	lgh_enddate   <=  @hoursoutdate AND
	lgh_instatus  <> 'HST' AND 
	lgh_instatus  =  'UNP' AND
	lgh_outstatus IN ( 'PLN',  'STD') and legheader.ord_hdrnumber > 0 AND
	left(trc_gps_desc,6) <> 'ESTADO'
	Order by 3

--Hacer un barrido de cada unos de los renglones de la tabla @TTAlertas para
-- insertar la alerta si es su caso.

	--'Abrir un cursor y recorrelo 
	DECLARE Unidades_Cursor CURSOR FOR 
		SELECT evt_tractor, legheader, ord_hdrnumber, trc_driver, skip_eta, ord_billto, mpp_lastfirst
		FROM @TTAlertas 
		OPEN Unidades_Cursor 
		FETCH NEXT FROM Unidades_Cursor INTO @unidad, @li_legheader, @li_noorden, @as_operador, @ls_skip_eta, @ls_billto, @ls_nombreoper
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- del cursor Unidades_Cursor --2
		SELECT @unidad, @li_legheader, @li_noorden, @as_operador, @ls_skip_eta, @ls_billto, @ls_nombreoper
		Select @li_yaenvioaleta = 0

	-- Aqui se revisa que el legheader tenga los tramos sin completar y que sean facturable.
	IF @li_legheader > 0 and @ls_skip_eta = 'N'
	BEGIN -- de cuando el legheader es mayor a 0 --3
	Select @li_numstop = 0
	-- obtiene el dato del stop que tiene aun sin terminar si es el caso.
 		select	 @li_numstop   	       = stp_mfh_sequence
			,@ls_stp_event         = s.stp_event
			,@ls_cty_nmstct        = ct.cty_nmstct
			,@ld_stp_arrivaldate   = s.stp_arrivaldate
			,@ld_stp_departuredate = s.stp_departuredate 
		from stops s
			join city ct on s.stp_city = ct.cty_code 
			left outer join eventcodetable ect on s.stp_event = ect.abbr
		where	s.lgh_number 	   = @li_legheader 	and 
			ect_billable 	   = 'Y' and 
			stp_status   	   = 'OPN'and  
			s.stp_mfh_sequence = (select Min(stp_mfh_sequence)
				from  stops s
				left outer join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
				left outer join eventcodetable ect on s.stp_event = ect.abbr
				where  s.lgh_number = @li_legheader and 
				ect_billable = 'Y' and 
				stp_status   = 'OPN')


		IF @li_numstop > 0   -- tramos por terminar
		BEGIN -- Inicio existe una parada facturable > 0 --4

			-- Toma el valor de la unidad para obtener los datos de sus posiciones
			Select @pos_act = (select max(ckc_number) from checkcall where ckc_tractor = @unidad )
			
			Select @Fecha_pos_act = (select ckc_date from checkcall where  ckc_number = @pos_act)
			
			-- Toma el valor de la posicion anterior.
			Select @pos_ant = (select max(ckc_number) from checkcall Where ckc_tractor = @unidad and ckc_number <> @pos_act )
			
			Select @Fecha_pos_ant = (select ckc_date from   checkcall where ckc_number = @pos_ant)
			
			-- Obtiene si el status del motor.
			Select @ls_ignitionAct = (select ckc_vehicleignition from   checkcall where   ckc_number =  @pos_act )
			Select @ls_ignitionAnt = (select ckc_vehicleignition from   checkcall where   ckc_number =  @pos_ant)
			
			-- Obtiene la descripcion de la posicion
			Select @ls_comentarioAct = (select ckc_comment from   checkcall where   ckc_number =  @pos_act )
			Select @ls_comentarioAnt = (select ckc_comment from   checkcall where   ckc_number =  @pos_ant )

-- Envio de alertas. Nivel 1
			--Si la diferencia entre las fechas de las posiciones es mayor a 15 min-- envia mensaje de alerta.
			select @li_minutos = (select DATEDIFF(mi, GETDATE(), @Fecha_pos_act) )
			IF @li_minutos <= -30 and @li_yaenvioaleta = 0
			BEGIN -- minutos mayor a 60 --5
				Select @liFolder 	= 0
				Select @lsDeliverTo 	= Null
 	
				SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
				       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
				       @li_flota = Trucks.CurrentDispatcher
				FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
				WHERE 	Trucks.Truckname = @unidad  and Cab.SN = Trucks.DefaultCabUnit

				-- Toma el nombre de la flota
				SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
				FROM tblDispatchGroup flota 
				WHERE SN = @li_flota
							
				
				Select @lsSubject 	= convert(varchar(10),@li_noorden)+' PERDIDA DE POSICION '+' / '+ @ls_comentarioAct 
				Select @lsContenido	=  'PERDIDA DE POSICION CEMS '+@ls_comentarioAct
				

				INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN )
				Values(4, 1, 1, 4, 3, GetDate(), GetDate(), @li_inboxflota, @lsContenido, @unidad, @lsSubject , @ls_nombreflota , @li_tbl_SN, @li_defaultdriver)

				Select @li_yaenvioaleta = 1 -- indica que ya se envio la alerta

				-- Pregunta si la perdida de posicion lleva mas de 90 min.
				-- o sea no se ha localizado la unidad por el CEMS
				IF @li_minutos <= -90 and @li_minutos >= -105
						BEGIN -- Begin 6
						-- Contenido del correo para perdida de posicion. Nivel 1
						select @lsContenido = 'Cte: ' + @ls_billto + ', Ult Pos:'+ @ls_comentarioAct + ', Op: '+@ls_nombreoper
							IF @ls_ce_nivel1 <> 'N' and  @ls_ce_nivel1 <> ''
							BEGIN
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
											FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN, OrigMsgSN, ReplyFormID, ReplyPriority )
								Values(1, 1, 1, 1, 2, GetDate(), Null, 
									365, @lsContenido, @unidad, '1.30H sin pos, Uni- '+@unidad +' '+@lsContenido, @ls_ce_nivel1 , @li_tbl_SN, @li_defaultdriver, 0,0,2)
							END
		
							IF @ls_ce_ccp_nivel1 <> 'N' and  @ls_ce_ccp_nivel1 <> ''
							BEGIN
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
											FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN, OrigMsgSN, ReplyFormID, ReplyPriority )
								Values(1, 1, 1, 1, 2, GetDate(), Null, 
									365, @lsContenido, @unidad, '1.30H sin pos, Uni- '+@unidad +' '+@lsContenido, @ls_ce_ccp_nivel1 , @li_tbl_SN, @li_defaultdriver, 0,0,2)
							END 
						END --end begin 6


				-- Pregunta si la perdida de posicion lleva mas de 105 min. NIVEL 2
				IF @li_minutos <= -105 and @li_minutos >= -120
						BEGIN -- begin 7
							select @lsContenido = 'Cte:' + @ls_billto + ', Ult Pos: '+ @ls_comentarioAct + ', Op. '+@ls_nombreoper
							
							IF @ls_ce_nivel2 <> 'N' and  @ls_ce_nivel2 <> ''
							BEGIN --7.1
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
											FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN, OrigMsgSN, ReplyFormID, ReplyPriority )
							Values(1, 1, 1, 1, 2, GetDate(), Null, 
								365, @lsContenido, @unidad, '1.45 H sin pos,Uni- '+@unidad +' '+@lsContenido , @ls_ce_nivel2 , @li_tbl_SN, @li_defaultdriver, 0, 0, 2)
							END --7.1
		
							IF @ls_ce_ccp_nivel2 <> 'N' and  @ls_ce_ccp_nivel2 <> ''
							BEGIN --7.2
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
											FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN, OrigMsgSN, ReplyFormID, ReplyPriority )
							Values(1, 1, 1, 1, 2, GetDate(), Null, 
								365, @lsContenido, @unidad, '1.45 H sin pos,Uni- '+@unidad +' '+@lsContenido , @ls_ce_ccp_nivel2 , @li_tbl_SN, @li_defaultdriver, 0, 0, 2)
							END --7.2
		
						END -- end begin 7
		

				-- Pregunta si la perdida de posicion lleva mas de 120 min ( 2rhs)
				IF @li_minutos <= -120
					BEGIN --begin 8
						select @lsContenido = 'Cte: ' + @ls_billto + ', Ult Pos: '+ @ls_comentarioAct + ', Op. '+@ls_nombreoper
							IF @ls_ce_nivel3 <> 'N' and  @ls_ce_nivel3 <> ''
							BEGIN -- 8.1
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
										FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN , OrigMsgSN, ReplyFormID, ReplyPriority )
								Values(1, 1, 2, 1, 2, GetDate(), Null, 
									365, @lsContenido, @unidad, '2H o + sin pos, Uni- '+@unidad+' '+@lsContenido , @ls_ce_nivel3 , @li_tbl_SN, @li_defaultdriver,0 , 0, 2)
							END --8.1  
	
							IF @ls_ce_ccp_nivel3 <> 'N' and @ls_ce_ccp_nivel3 <> ''
							BEGIN --8.2
								INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, 
										FOLDER, Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN , OrigMsgSN, ReplyFormID, ReplyPriority )
								Values(1, 1, 2, 1, 2, GetDate(), Null, 
									365, @lsContenido, @unidad, '2H o + sin pos, Uni- '+@unidad+' '+@lsContenido , @ls_ce_ccp_nivel3 , @li_tbl_SN, @li_defaultdriver,0 , 0, 2)
							END  -- 8.2
					END -- en begin 8

			END -- minutos mayor a 60 --6

			IF @li_minutos <= -15 and @li_yaenvioaleta = 0
			BEGIN -- minutos mayor a 60 --6.1
				Select @liFolder 	= 0
				Select @lsDeliverTo 	= Null
 	
				SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
				       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
				       @li_flota = Trucks.CurrentDispatcher
				FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
				WHERE 	Trucks.Truckname = @unidad  and Cab.SN = Trucks.DefaultCabUnit

				-- Toma el nombre de la flota
				SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
				FROM tblDispatchGroup flota 
				WHERE SN = @li_flota
							
				
				Select @lsSubject 	= convert(varchar(10),@li_noorden)+' Checkcall Request CEMS '+' / '+ @ls_comentarioAct 
				Select @lsContenido	=  'Checkcall Request CEMS '+@ls_comentarioAct

				
				INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN )
				Values(5, 1, 1, 4, 3, GetDate(), GetDate(), @liFolder, @lsContenido, @unidad, @lsSubject , @ls_nombreflota , @li_tbl_SN, @li_defaultdriver)


				Select @li_yaenvioaleta = 1 -- indica que ya se envio la alerta

			END -- minutos mayor a 15 --6.1
			
-- Si el motor pasa de 'N' a 'Y'
			IF @ls_ignitionAct = 'Y' and @ls_ignitionAnt = 'N' and @li_yaenvioaleta = 0
			BEGIN --5
				Select @liFolder 	= 0
				Select @lsDeliverTo 	= Null

				SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
				       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
				       @li_flota = Trucks.CurrentDispatcher
				FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
				WHERE 	Trucks.Truckname = @unidad  and Cab.SN = Trucks.DefaultCabUnit

				-- Toma el nombre de la flota
				SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
				FROM tblDispatchGroup flota 
				WHERE SN = @li_flota


				IF @ls_comentarioAnt <> @ls_comentarioAct
				Begin --5.2
					Select @lsSubject 	= convert(varchar(10),@li_noorden)+ ' DETECCION DE MOVIMIENTO '+' / '+ @unidad 
					Select @lsContenido	=  'DETECCION DE MOVIMIENTO CEMS'

					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
					Values(4, 1, 1, 4, 3, GetDate(), GetDate(), @liFolder, @lsContenido, @unidad, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)
	
					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
					Values(4, 1, 1, 4, 3, GetDate(), GetDate(), @li_inboxflota, @lsContenido, @unidad, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)
					Select @li_yaenvioaleta = 1 -- indica que ya se envio la alerta
				End  --5.2
			END --5

			IF @ls_ignitionAct = 'N' and @ls_ignitionAnt = 'Y' and @li_yaenvioaleta = 0
			BEGIN --5.1
				Select @liFolder 	= 0
				Select @lsDeliverTo 	= Null

				SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
				       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
				       @li_flota = Trucks.CurrentDispatcher
				FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
				WHERE 	Trucks.Truckname = @unidad  and Cab.SN = Trucks.DefaultCabUnit

				-- Toma el nombre de la flota
				SELECT @ls_nombreflota = flota.Name, @li_inboxflota = Inbox 
				FROM tblDispatchGroup flota 
				WHERE SN = @li_flota

				IF @ls_comentarioAnt <> @ls_comentarioAct
				Begin --5.4
					Select @lsSubject 	= convert(varchar(10),@li_noorden)+ ' DETECCION DE PARADA '+' / '+ @unidad 
					Select @lsContenido	=  'DETECCION DE PARADA CEMS '
				

					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
					Values(4, 1, 1, 4, 3, GetDate(), GetDate(), @liFolder, @lsContenido, @unidad, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)
	
					INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN)
					Values(4, 1, 1, 4, 3, GetDate(), GetDate(), @li_inboxflota, @lsContenido, @unidad, @lsSubject , @ls_nombreflota, @li_tbl_SN, @li_defaultdriver)
					Select @li_yaenvioaleta = 1 -- indica que ya se envio la alerta
				End   --5.4
			END --5.1


		END --de cuando existe una parada facturable  --4

	END --de cuando @li_legheader > 0  and @ls_skip_eta = 'N' --3@li_numstop

	FETCH NEXT FROM Unidades_Cursor INTO @unidad, @li_legheader, @li_noorden, @as_operador, @ls_skip_eta, @ls_billto, @ls_nombreoper
	
END -- curso de la unidades --2??
CLOSE Unidades_Cursor 
DEALLOCATE Unidades_Cursor 

END --  del Begin Principal --1
-- Toma los valores de la unidad, -- e inserta el mensaje


GO
