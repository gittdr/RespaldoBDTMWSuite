CREATE TABLE [dbo].[checkcall]
(
[ckc_number] [int] NOT NULL,
[ckc_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ckc_asgntype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ckc_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_date] [datetime] NOT NULL,
[ckc_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ckc_city] [int] NULL,
[ckc_comment] [char] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ckc_updatedon] [datetime] NOT NULL,
[ckc_latseconds] [int] NULL,
[ckc_longseconds] [int] NULL,
[ckc_lghnumber] [int] NULL,
[ckc_tractor] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_extsensoralarm] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_vehicleignition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_milesfrom] [float] NULL,
[ckc_directionfrom] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_validity] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mtavailable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_minutes] [int] NULL,
[ckc_mileage] [int] NULL,
[ckc_home] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_cityname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_commentlarge] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_minutes_to_final] [int] NULL,
[ckc_miles_to_final] [int] NULL,
[ckc_Odometer] [int] NULL,
[TripStatus] [int] NULL,
[ckc_odometer2] [int] NULL,
[ckc_speed] [int] NULL,
[ckc_speed2] [int] NULL,
[ckc_heading] [float] NULL,
[ckc_gps_type] [int] NULL,
[ckc_gps_miles] [float] NULL,
[ckc_fuel_meter] [float] NULL,
[ckc_idle_meter] [int] NULL,
[ckc_ExtraData01] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData02] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData03] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData04] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData05] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData06] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData07] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData08] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData09] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData11] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData12] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData13] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData14] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData15] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData16] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData17] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData18] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData19] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_ExtraData20] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_subsistence_qualified] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mcommsystem] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mcommcity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mcommcitystate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mcommsplc] [int] NULL,
[ckc_mcommfence] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_mcommfenceevent] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_AssociatedMsgSN] [int] NULL,
[ckc_TimeZone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_QCTTEvent] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_miles_to_next] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create trigger [dbo].[dt_checkcall] on [dbo].[checkcall] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/* Revision History:
	Date		Name			PTS		Description
	-----------	---------------	-------	-----------------------------------------------------
	01/24/2003	Vern Jewett		16885	Original, copied from CTX source & modified.
*/

declare @lgh_number 		int
		,@ls_CtxActiveLegs	char(1)


--don't fire if they are purging
if (select count(*) from deleted) > 1 
	return


--Get the GeneralInfo setting to determine if we need to do this or not..
select	@ls_CtxActiveLegs = isnull(upper(left(gi_string1, 1)), 'N')
  from	generalinfo
  where	gi_name = 'CTXActiveLegs'
if @ls_CtxActiveLegs = ''
	select @ls_CtxActiveLegs = 'N'
if @ls_CtxActiveLegs <> 'Y'
	return


--Update ctx_active_legs.last_ckc_time where appropriate..
select @lgh_number = 0

--skip 0
while exists (select * from deleted
		where ckc_lghnumber > @lgh_number and
			ckc_updatedby <> 'TMAIL')
begin
	select @lgh_number = min(CKC_lghnumber)
	from deleted
	where ckc_lghnumber > @lgh_number  and
		ckc_updatedby <> 'TMAIL'

	if (select lgh_outstatus from  ctx_active_legs
		where lgh_number = @lgh_number) = 'STD'
		update ctx_active_legs
		set  last_ckc_time = (select max(ckc_date)
					 from   checkcall 
					 where  ckc_lghnumber = @LGH_NUMBER  and
						ckc_updatedby <> 'TMAIL')
		where ctx_active_legs.lgh_number = @lgh_number
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[it_checkcall] ON [dbo].[checkcall]
FOR INSERT,UPDATE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 


DECLARE	@citystct 			varchar(25),
        @lgh_number 			int,
        @mov_number 			int,
        @ord 				int,
	@cty_code 			int,
	@ls_audit			varchar(1),
	@ls_CtxActiveLegs		char(1),
	@maptuitgeocode			char(1),
	@tractor			char(8),
	@lat				int,
	@lon				int,
	@latitude			decimal(7,4),
	@longitude			decimal(7,4),
	@maptuit_geocode		char(1),
	@m2qhid				int,
	@external_type			varchar(6),
	@external_id			int,
	@ckc_number				int,
	@ls_audit2				char(1),
	@ckc_event			varchar(6)
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--IF (SELECT ckc_updatedby FROM inserted) <> 'TMAIL'
BEGIN
   IF (SELECT gi_string1
   FROM generalinfo
   WHERE gi_name = 'ChkCllGPSUpd') = 'YES'
   BEGIN
	IF (SELECT count(*)
	FROM checkcall with (nolock) /*57465*/,inserted
	WHERE checkcall.ckc_tractor = inserted.ckc_tractor and
	              checkcall.ckc_date > inserted.ckc_date) = 0
	BEGIN
	   SELECT @citystct = cty_nmstct
			, @cty_code = cty_code
	   FROM city with (nolock) /*57465*/,inserted
	   WHERE city.cty_code = inserted.ckc_city
	   
	   IF (SELECT ckc_updatedby FROM inserted) <> 'TMAIL'
	   BEGIN
		IF @citystct = 'UNKNOWN'
	           UPDATE tractorprofile
	           SET trc_gps_desc = LEFT(RTRIM(ISNULL(ckc_comment,' ')),45)
	                , trc_gps_date = ckc_date
			, trc_gps_latitude = IsNull(ckc_latseconds, 0)
			, trc_gps_longitude = IsNull(ckc_longseconds, 0)
        	   FROM inserted
	           WHERE ckc_tractor <> 'UNKNOWN' and
	                trc_number = ckc_tractor

		ELSE
	           UPDATE tractorprofile
	           SET trc_gps_desc = LEFT(@citystct + '  ' + RTRIM(ISNULL(ckc_comment,' ')), 45),
	                trc_gps_date = ckc_date
			, trc_gps_latitude = IsNull(ckc_latseconds, 0)
			, trc_gps_longitude = IsNull(ckc_longseconds, 0)
	           FROM inserted
	           WHERE ckc_tractor <> 'UNKNOWN' and
	                trc_number = ckc_tractor
	   END 
	   IF @cty_code > 0 
		UPDATE	tractorprofile
		SET		trc_avl_city = @cty_code
		FROM		inserted
		WHERE		ckc_tractor <> 'UNKNOWN'
		  AND		trc_number = ckc_tractor
		  AND		trc_status = 'AVL'
	END
   END
END

/*PTS9844 MBR 1/29/01 Added a check call fingerprint audit record to be added to the expedite_audit
  table when a check call record is added for the order. */
--vmj1+	Multiple gi_datein's weren't being handled..
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
--JLB PTS 26330 allow this to be shut off without shutting off fingerprint audit for performance
select @ls_audit2 = isnull(upper(substring(generalinfo.gi_string1, 1, 1)), 'Y')
  from generalinfo
 where gi_name = 'LogCkcTransfersWithFPAudit'
if @ls_audit = 'Y' and @ls_audit2 = 'Y'
--end 26330
BEGIN
	--vmj1+	PTS 12286	02/22/2002	Need to include Order # where possible..
	insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name)
	  select isnull(lh.ord_hdrnumber, 0)
			--vmj2+	PTS 16425	12/07/2002	updated_by is varchar(20), but suser_sname may exceed that length..
			,upper(left(@tmwuser, 20))
--			,upper(suser_sname())
			--vmj2-
			,'CHECKCALL'
			,getdate()
			,ltrim(rtrim(i.ckc_asgntype)) + ' ' + ltrim(rtrim(i.ckc_asgnid)) + ' ' + ltrim(rtrim(i.ckc_event)) + 
				' at ' + isnull(ltrim(rtrim(c.cty_nmstct)) + ' ', '') + 
				isnull(convert(varchar(12), i.ckc_latseconds) + ' ', '') + 
				isnull(convert(varchar(12), i.ckc_longseconds) + ' ', '')
			,i.ckc_number
			,isnull(lh.mov_number, 0)
			,i.ckc_lghnumber
			,'checkcall'
	  from	inserted i
				left outer join legheader lh  with (nolock) /*57465*/ on i.ckc_lghnumber = lh.lgh_number
				left outer join city c  with (nolock) /*57465*/ on i.ckc_city = c.cty_code
--   SELECT @lgh_number = inserted.ckc_lghnumber
--      FROM inserted
--   set @mov_number = (SELECT mov_number from legheader where lgh_number = @lgh_number)
--   set @ord = (SELECT Min(ord_hdrnumber) FROM orderheader WHERE mov_number = @mov_number)
--   IF @ord IS NULL
--	set @ord = 0
--   insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
--                            values   (@ord, UPPER(SUSER_SNAME()), GETDATE(), 'CHECKCALL')
	--vmj1-
END

-- PTS22080 KMM MAPTUIT INTEGRATION
BEGIN
   SELECT @maptuit_geocode = Upper(isnull(gi_string1,'N'))
     FROM generalinfo
    WHERE gi_name = 'MaptuitAlert'
    
   SELECT @ckc_event = isnull(ckc_event,'ZZZ')
     FROM inserted

   IF @maptuit_geocode = 'Y' AND @ckc_event = 'TRP'
   BEGIN

	select @tractor = inserted.ckc_tractor from inserted
	SELECT @lat = ckc_latseconds, @lon = ckc_longseconds FROM inserted
	SET @lon = @lon * -1
	SET @latitude = @lat/3600.0000
	SET @longitude = @lon/3600.0000
	
   EXECUTE @m2qhid = getsystemnumber 'M2QHID',''
	INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
	VALUES (@m2qhid, 'Lat', 'HIL', convert(varchar, @latitude) + 'd')
   INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
	VALUES (@m2qhid, 'Lon', 'HIL', convert(varchar, @longitude) + 'd')
   INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
	VALUES (@m2qhid, 'Timestamp', 'HIL', convert(varchar, getdate(),120))
   INSERT INTO m2msgqdtl (m2qdid, m2qdkey, m2qdcrtpgm, m2qdvalue)
	VALUES (@m2qhid, 'UnitID', 'HIL', @tractor)
	INSERT INTO m2msgQhdr VALUES (@m2qhid, 'PositionReport', getdate(), 'R')
    END
END
-- END PTS22080 MAPTUIT INTEGRATION

--PTS26330 JLB 01/03/05 NLM Tracking
SELECT @lgh_number = isnull(inserted.ckc_lghnumber,0),
       @tractor = isnull(inserted.ckc_tractor,'UNKNOWN'),
       @external_type = isnull(orderheader.external_type,'XXX'),
       @external_id = isnull(orderheader.external_id,0),
       @ckc_number = inserted.ckc_number,
       @ckc_event = isnull(inserted.ckc_event,'ZZZ')
  FROM inserted, legheader  with (nolock) /*57465*/ , orderheader  with (nolock) /*57465*/ 
 WHERE inserted.ckc_lghnumber = legheader.lgh_number
   AND legheader.ord_hdrnumber = orderheader.ord_hdrnumber

IF @lgh_number > 0 AND @tractor <> 'UNKNOWN' and @external_type = 'NLM' and @external_id > 0 and @ckc_event = 'TRP'
        INSERT INTO nlmvehicletracking (ckc_number, process_time)
			VALUES (@ckc_number, getdate())
--end 26330

--vmj3+	PTS 16885	01/24/2003
select	@ls_CtxActiveLegs = isnull(upper(left(ltrim(rtrim(g1.gi_string1)), 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'CTXActiveLegs'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'CTXActiveLegs'
							and	g2.gi_datein <= getdate())
if @ls_CtxActiveLegs = ''
	select @ls_CtxActiveLegs = 'N'
/*JLB PTS 35870 do not return if this setting is off just don't run this piece of logic
if @ls_CtxActiveLegs <> 'Y'
	return
*/
if @ls_CtxActiveLegs <> 'Y'
begin
	select @lgh_number = 0
	--skip 0
	while exists (select * from inserted
			where ckc_lghnumber > @lgh_number and
				ckc_updatedby <> 'TMAIL')
	begin
		select @lgh_number = min(CKC_lghnumber)
		from inserted
		where ckc_lghnumber > @lgh_number  and
			ckc_updatedby <> 'TMAIL'

		if (select lgh_outstatus from  ctx_active_legs
			where lgh_number = @lgh_number) = 'STD'
			update ctx_active_legs
			set  last_ckc_time = (select max(ckc_date)
						 from   checkcall   with (nolock) /*57465*/ 
						 where  ckc_lghnumber = @LGH_NUMBER  and
							ckc_updatedby <> 'TMAIL')
			where ctx_active_legs.lgh_number = @lgh_number
	end
	--vmj3-
end  --end 35870

--JLB PTS 34406 Take the GPS info to the driver profile if the driver is provided
IF (SELECT gi_string1
      FROM generalinfo
     WHERE gi_name = 'ChkCllGPSUpd') = 'YES'
BEGIN
     IF (SELECT count(*)
	      FROM checkcall  with (nolock) /*57465*/ ,inserted
	     WHERE checkcall.ckc_asgnid = inserted.ckc_asgnid and
	           checkcall.ckc_date > inserted.ckc_date  and 
                checkcall.ckc_asgntype = 'DRV') = 0
	BEGIN
	   SELECT @citystct = cty_nmstct
			, @cty_code = cty_code
	   FROM city,inserted
	   WHERE city.cty_code = inserted.ckc_city
	   
	   IF (SELECT ckc_updatedby FROM inserted) <> 'TMAIL'
	   BEGIN
		IF @citystct = 'UNKNOWN'
	           UPDATE manpowerprofile
	           SET mpp_gps_desc = LEFT(RTRIM(ISNULL(ckc_comment,' ')),45),
	               mpp_gps_date = ckc_date,
			     mpp_gps_latitude = IsNull(ckc_latseconds, 0),
			     mpp_gps_longitude = IsNull(ckc_longseconds, 0)
        	   FROM inserted
	           WHERE ckc_asgnid <> 'UNKNOWN' and
	                 mpp_id = ckc_asgnid and
                      ckc_asgntype = 'DRV'

		ELSE
	           UPDATE manpowerprofile
	           SET mpp_gps_desc = LEFT(@citystct + '  ' + RTRIM(ISNULL(ckc_comment,' ')), 45),
	               mpp_gps_date = ckc_date,
			     mpp_gps_latitude = IsNull(ckc_latseconds, 0),
			     mpp_gps_longitude = IsNull(ckc_longseconds, 0)
	           FROM inserted
	           WHERE ckc_asgntype = 'DRV' and 
                      ckc_asgnid <> 'UNKNOWN' and
	                 mpp_id = ckc_asgnid
	   END 
	   IF @cty_code > 0 
		UPDATE	manpowerprofile
		SET		mpp_avl_city = @cty_code
		FROM		inserted
		WHERE		ckc_asgnid <> 'UNKNOWN'
            AND          ckc_asgntype = 'DRV'
		  AND		mpp_id = ckc_asgnid
		  AND		mpp_status = 'AVL'
     END
END
--end 34406

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 4/10/2017
-- Description:	Triger que realizar acciones de totalmail
-- para la aplicacion convoy360 y skybits.

-- =============================================
CREATE TRIGGER [dbo].[it_tmconvoyactions]
   ON  [dbo].[checkcall]
   FOR INSERT,UPDATE 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   


 declare @trltype varchar(10)
 declare @unidad varchar(10)
 declare @geofence varchar(200)
 declare @leg varchar(10)
 declare @orden varchar(10)
 declare @actcmp varchar(20)
 declare @nextcmp varchar(50)
 declare @ubicacion varchar(255)
  declare @sitioxsalir varchar(255)
 declare @mensajetotalmail varchar(255)
 
 
 select 

 @trltype = ckc_asgntype,
 @unidad = ckc_asgnid,
 @geofence = ckc_mcommfence,
 @leg = ckc_lghnumber,
 @ubicacion = ckc_comment

 from inserted


--Insertar los datos de skybits en el campo trl_misc4 de trailerprofile ya que no opera bien el
--proceso del webservice de skybits para formar la cadena de texto.

  iF (@trltype  = 'TRL')
   BEGIN
    update trailerprofile set trl_misc4 = (select ckc_comment from inserted)
	where trl_number =  @unidad

	update trailerprofile set trl_division = isnull(case when  trl_misc4 like '%Empty%' then 'EMP'
     when trl_misc4  like '%Loaded%' then 'LDL'
	 end,'UNK') where trl_status <> 'OUT'


 END
------------------------------------------------------------------------------------------------
--Si tenemos un leg en el que esta la unidad y la geocerca no es nula procedemos a generar el 
-- mensaje de TOTALMAIL  para avisar al operador en su APP de CONVOY360 que se detecto entrada o salida


 if ((@leg is not null) and (@geofence is not null))
  BEGIN
    

	select @orden = (select ord_hdrnumber from legheader (nolock) where lgh_number = @leg)



--obtenemos la compañia  proxima y la actual del leg en cuestion--------
	select 
	@nextcmp = ns.cmp_id,
	@actcmp = cs.cmp_id

	 from legheader lgh

	 LEFT OUTER JOIN (
							SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
							FROM stops WITH (NOLOCK)
							WHERE stp_departure_status = 'OPN' and  stp_status = 'OPN'
							GROUP BY mov_number, lgh_number
							) sig ON lgh.lgh_number = sig.lgh_number
						LEFT OUTER JOIN stops ns WITH (NOLOCK) ON sig.mov_number = ns.mov_number and sig.StopSequence = ns.stp_mfh_sequence

	 LEFT OUTER JOIN (
                   SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
                   FROM stops WITH (NOLOCK)
                   WHERE stp_departure_status = 'OPN' and stp_status = 'DNE'
                  GROUP BY mov_number, lgh_number
                  ) seq ON lgh.lgh_number = seq.lgh_number
                   LEFT OUTER JOIN stops cs WITH (NOLOCK) ON seq.mov_number = cs.mov_number and seq.StopSequence = cs.stp_mfh_sequence

	where lgh.lgh_number = @leg

---si la ubicacion es entrando------

   if (@ubicacion like '%Entrando a:%')
   BEGIN
    If ('['+ @nextcmp + ']' = @geofence)
	BEGIN
	select @mensajetotalmail = 'Entrando a:  ' + @geofence + ' actualiza tu orden ->  ' + @orden
	 exec tm_insertamensaje @mensajetotalmail, @unidad
	END
   END

---si la ubicacion es saliendo------

   if (@ubicacion like '%Saliendo de:%')
   BEGIN
     select @sitioxsalir =  ( select rtrim(ltrim(replace(replace(replace(replace(replace(substring(@ubicacion,0, charindex('|',@ubicacion)),'Saliendo de:',''),'[Y]',''),'[N]',''),'[',''),']',''))))

    If (@actcmp =  @sitioxsalir)
	BEGIN
	select @mensajetotalmail = 'Saliendo de:  ' + @actcmp + ' actualiza tu orden -> ' + @orden 
	 exec tm_insertamensaje @mensajetotalmail, @unidad
	END
   END





  END

------------------------------------------------------------------------------------------------ 

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE     TRIGGER  [dbo].[tg_ckcmirrow]
ON  [dbo].[checkcall]
After insert 
AS 

SET NOCOUNT ON  
declare	
 @fecha  datetime
 ,@comentario  char(254)
 ,@tractor char(8)
 ,@longitudsec int
 ,@latitudsec int 
 
/*--------------------------------------------------------------*/
        SELECT @fecha = ckc_date, 
		@comentario = ckc_comment,
		@tractor =  ckc_tractor ,
                @longitudsec = ckc_longseconds,
                @latitudsec = ckc_latseconds
              FROM inserted
	 
	insert into checkmirrow (ckh_Date,ckh_comment,ckh_tractor,ckh_lonseconds,ckh_latseconds) VALUES (@fecha,@comentario,@tractor,@longitudsec, @latitudsec)
       






GO
DISABLE TRIGGER [dbo].[tg_ckcmirrow] ON [dbo].[checkcall]
GO
ALTER TABLE [dbo].[checkcall] ADD CONSTRAINT [uk_number] PRIMARY KEY CLUSTERED ([ckc_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ckc_asgnid_event_date] ON [dbo].[checkcall] ([ckc_asgnid], [ckc_event], [ckc_date] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_typeid] ON [dbo].[checkcall] ([ckc_asgntype], [ckc_asgnid], [ckc_date]) INCLUDE ([ckc_city], [ckc_comment], [ckc_updatedby], [ckc_updatedon], [ckc_cityname], [ckc_state], [ckc_commentlarge]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ckc_asgntype_trc_date] ON [dbo].[checkcall] ([ckc_asgntype], [ckc_tractor], [ckc_date]) INCLUDE ([ckc_latseconds], [ckc_longseconds]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ckc_asgntype] ON [dbo].[checkcall] ([ckc_asgntype], [ckc_updatedon]) INCLUDE ([ckc_asgnid], [ckc_date], [ckc_latseconds], [ckc_longseconds], [ckc_tractor], [ckc_milesfrom], [ckc_directionfrom], [ckc_cityname], [ckc_state]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [checkcall0] ON [dbo].[checkcall] ([ckc_date], [ckc_asgntype], [ckc_asgnid], [ckc_tractor]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ckc_lghnumber] ON [dbo].[checkcall] ([ckc_lghnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ckc_lghnum] ON [dbo].[checkcall] ([ckc_lghnumber]) INCLUDE ([ckc_date], [ckc_latseconds], [ckc_longseconds]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ckc_lghnum_date_lat_long] ON [dbo].[checkcall] ([ckc_lghnumber], [ckc_date], [ckc_latseconds], [ckc_longseconds]) INCLUDE ([ckc_status], [ckc_asgntype], [ckc_asgnid], [ckc_event], [ckc_city], [ckc_comment], [ckc_updatedby], [ckc_updatedon], [ckc_tractor], [ckc_extsensoralarm], [ckc_vehicleignition], [ckc_milesfrom], [ckc_directionfrom], [ckc_validity], [ckc_mtavailable], [ckc_mileage], [ckc_minutes], [ckc_home], [ckc_minutes_to_final], [ckc_miles_to_final], [ckc_commentlarge]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ckc_trc_asgn_updby_type_event_dt] ON [dbo].[checkcall] ([ckc_tractor], [ckc_asgnid], [ckc_updatedby], [ckc_asgntype], [ckc_event], [ckc_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ckc_2] ON [dbo].[checkcall] ([ckc_tractor], [ckc_date], [ckc_latseconds], [ckc_longseconds]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[checkcall] TO [public]
GO
GRANT INSERT ON  [dbo].[checkcall] TO [public]
GO
GRANT REFERENCES ON  [dbo].[checkcall] TO [public]
GO
GRANT SELECT ON  [dbo].[checkcall] TO [public]
GO
GRANT UPDATE ON  [dbo].[checkcall] TO [public]
GO
