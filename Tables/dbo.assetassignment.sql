CREATE TABLE [dbo].[assetassignment]
(
[lgh_number] [int] NULL,
[asgn_number] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_date] [datetime] NULL,
[asgn_eventnumber] [int] NULL,
[asgn_controlling] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_dispdate] [datetime] NULL,
[asgn_enddate] [datetime] NULL,
[asgn_dispmethod] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[timestamp] [timestamp] NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_number] [int] NULL,
[asgn_trl_first_asgn] [int] NULL,
[asgn_trl_last_asgn] [int] NULL,
[last_evt_number] [int] NULL,
[last_dne_evt_number] [int] NULL,
[next_opn_evt_number] [int] NULL,
[aa_nonprimary_asset] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_pay_usedate] [datetime] NULL,
[asgn_pay_usedate_setting] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[termCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleId] [int] NULL,
[asgn_pld_event] [int] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__assetassi__INS_T__322C25F1] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_assetassignment_consolidated] ON [dbo].[assetassignment] FOR DELETE  AS 
/* PTS# 3286 PG 11/13/97 */
/* PTS# 3656 MF did nothing just making sure it is in 4.0 release */
/* PTS# 34312 JG, 08/31/2006, consolidate and optimize trigger */

SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @id 		char(13),-- 10/03/07 SGB PTS 39701 Changed from 8 to 13
	@minasgn 	int,
	@type 		char(3),
	@manhattan	char(1)

BEGIN

	--PTS34312 prevent empty firing
	if not exists (select 1 from deleted) return
	--PTS34312 end
	
	SELECT @minasgn = 0
	WHILE 1=1
	BEGIN
		SELECT 	@minasgn = MIN ( asgn_number ) 
		FROM 	deleted
		WHERE 	asgn_number > @minasgn

		IF @minasgn IS NULL
			BREAK

		SELECT 	@type = asgn_type, @id = asgn_id 
		FROM 	deleted 
		WHERE 	asgn_number = @minasgn 
	 
		IF @type = 'TRC'
		BEGIN
			EXECUTE instatus @id
/* PTS# 3286 */
			EXECUTE trc_expstatus @id
/* End PTS# 3286 */
		END
		IF @type = 'TRL'
			EXECUTE trl_expstatus @id
		IF @type = 'DRV'
/* PTS# 3286 */
			EXECUTE drv_expstatus @id
/* End PTS# 3286 */
	END

	-- RE - PTS #62423 BEGIN
	IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'VHOS_Interface' AND LEFT(gi_string1,1) = 'Y')
	BEGIN
		INSERT INTO AOS_Tractor_Queue
			(trc_number)
			SELECT	asgn_id
			  FROM	deleted
			 WHERE	asgn_type = 'TRC'
	END
	-- RE - PTS #62423 END
END
return
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_assetassignment_consolidated] on [dbo].[assetassignment] for insert
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*  created for 

  DPETE PTS16846 1/22/03 TMI imaging vendor wants flat file index info on all order legs with assets
  JG PTS34312 08/31/06 consolidate and optimize trigger                 
  BPISK PTS37339 06-01-2007 Added TMIImageTripStatus to generalinfo for user defined codes
  PMILL 42166/49873 11/6/2009 added FlyingJ imaging vendor

*/
declare @tripPakStatus varchar(256);

--PTS 62529 JJF 20120705
DECLARE @tmwuser varchar (255)
--END PTS 62529 JJF 20120705

--PTS34312 prevent empty firing
if not exists (select 1 from inserted) return
--PTS34312 end

If Exists (Select gi_string1 from generalinfo where gi_name in( 'ImagingVendorInHouse','ImagingVendorOnRoad')  and gi_string1 IN ('TMIORDONLY', 'TMI', 'FLYINGJ'))  --pmill 42166/49873 added flyingJ
Begin
--PTS37339 begin
     select @tripPakStatus  = coalesce(gi_string1,'DSP,STD,CMP,ICO') from generalinfo where gi_name = 'TMIImageTripStatus'

     if (@tripPakStatus is null or ltrim(@tripPakStatus) = '')
         set @tripPakStatus = 'DSP,STD,CMP,ICO';

     set @tripPakStatus = ',' + @tripPakStatus + ',';

	  Insert into ImageOrderList (ord_hdrnumber)
     Select Distinct ord_hdrnumber
     From stops with (nolock), inserted
	  Where stops.lgh_number = inserted.lgh_number
	  And stops.ord_hdrnumber > 0 
     And not exists (Select * from ImageOrderList i with (nolock) Where i.ord_hdrnumber = stops.ord_hdrnumber)
     And Exists (Select ord_unit From orderheader with (nolock) Where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
     and 0 < charindex(',' + orderheader.ord_status + ',', @tripPakStatus))
--PTS37339 end
  END

If Exists (Select gi_string1 from generalinfo where gi_name in( 'ImagingVendorInHouse','ImagingVendorOnRoad')  and gi_string1 in ('TMI','FLYINGJ')) --pmill 42166/49873 added flyingJ
Begin
	declare @ordcount	int,
			@min		int

	select	@min = min(mov_number)
	  from	inserted	

	while isnull(@min, -1) <> -1
	begin
		select	@ordcount = count(mov_number)
		  from	stops with (nolock)
		 where	mov_number = @min and
				ord_hdrnumber <> 0

		if @ordcount = 0 
		begin
			if (select count(mov_number) from imagemovelist with (nolock) where mov_number = @min) = 0
			begin
				insert into imagemovelist (mov_number) values (@min)
			end
		end
		
		select	@min = min(mov_number)
		  from	inserted
		 where	mov_number > @min
	end
--		 Insert  into ImageMoveList (mov_number)
--		 Select Distinct (mov_number)
--		 From Inserted
--		 Where not exists (Select mov_number From ImageMoveList i Where i.mov_number = inserted.mov_number)
--		 And not exists (Select stp_type From stops s Where s.mov_number = inserted.mov_number and ord_hdrnumber > 0)
End


-- PTS 21890 - DJM - Modified SQL from PTS 18042 to improve performance.  Added to q: and
--	2003 source.
update paydetail
set asgn_number = pydnum.asgn_number
from (select paydetail.pyd_number, inserted.asgn_number
	From Paydetail  with (nolock), inserted 
	where paydetail.lgh_number = inserted.lgh_number
		and paydetail.asgn_id = inserted.asgn_id 
		and paydetail.asgn_type = inserted.asgn_type
		AND IsNull(paydetail.asgn_number,0) = 0) pydnum
where paydetail.pyd_number = pydnum.pyd_number

-- RE - PTS #62423 BEGIN
IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'VHOS_Interface' AND LEFT(gi_string1,1) = 'Y')
BEGIN
	INSERT INTO AOS_Tractor_Queue
		(trc_number)
		SELECT	asgn_id
		  FROM	inserted
		 WHERE	asgn_type = 'TRC'
END
-- RE - PTS #62423 END

--PTS 62529 JJF 20120705
IF  EXISTS	(	SELECT	*
				FROM	generalinfo
				WHERE	gi_name = 'AssignmentPermissions'
						AND gi_string1 = 'Y'
			)  BEGIN
	
	exec gettmwuser @tmwuser output
	
	UPDATE	AssignmentPermissons
	SET		ap_active = 'N'
	FROM	inserted i
	WHERE	ap_userid = @tmwuser
			AND ap_assettype = i.asgn_type
			AND ap_assetid = i.asgn_id
			AND ap_singleuse = 'Y'
END
--END PTS 62529 JJF 20120705

-- RE - PTS #66202 BEGIN
IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'Manhattan_Interface' AND LEFT(gi_string1,1) = 'Y')
BEGIN
	UPDATE	tractorprofile
	   SET	trc_optimization_staging_customer = 'UNKNOWN',
			trc_optimization_modeling_flag = NULL,
			trc_reload_status = 'UNK'
	 WHERE	trc_number IN (SELECT asgn_id FROM inserted WHERE asgn_type = 'TRC')
	   AND	(ISNULL(trc_optimization_staging_customer, 'UNKNOWN') <> 'UNKNOWN'
	    OR	 ISNULL(trc_optimization_modeling_flag, 'X') <> 'X'
		OR	 ISNULL(trc_reload_status, 'UNK') <> 'UNK')
END
-- RE - PTS #66202 END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 11 sept 2017
-- Description:	enviar aviso de  asignacion de orden por totalmail
-- =============================================
CREATE TRIGGER [dbo].[it_avisoasignaciontmail]
   ON  [dbo].[assetassignment] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 declare @mensaje as varchar(max)
	 declare @destino as  varchar(10)
	 
	 
	 select  @mensaje =  (select 'Tienes una nueva orden asignada:  ' +  cast(l.ord_hdrnumber as varchar(20))),
	 @destino  = (select mpp_tractornumber from manpowerprofile (nolock)  where mpp_id =  asgn_id)
	 from inserted  a
	 left join legheader (nolock) l on l.lgh_number =  a.lgh_number
	 where a.asgn_type = 'DRV'

	 exec tm_insertamensaje @mensaje , @destino


END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_assetassignment_consolidated] on [dbo].[assetassignment] for update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*  created for 

  DPETE PTS16846 1/22/03 TMI imaging vendor wants flat file index info on all order legs with assets
  JG PTS34312 08/31/06 consolidate and optimize trigger, add conditional check                 
  BPISK PTS37339 06-01-2007 Added TMIImageTripStatus to generalinfo for user defined codes
  PMILL 42166/49873 11/6/2009 added FlyingJ imaging vendor
  MCURN 79330 06/16/2014 added nolock to prevent deadlocks at CRE.
  MCURN	79441 07/02/2014 removed index hint
*/
declare @tripPakStatus varchar(256);

--PTS 62529 JJF 20120705
DECLARE @tmwuser varchar (255)
--END PTS 62529 JJF 20120705

--PTS34312 prevent empty firing
if not exists (select 1 from inserted) and not exists (select 1 from deleted) return
--PTS34312 end


If Exists (Select gi_string1 from generalinfo where gi_name in( 'ImagingVendorInHouse','ImagingVendorOnRoad')  and gi_string1 IN ('TMIORDONLY', 'TMI', 'FLYINGJ')) --pmill 42166/49873 added flyingJ
  Begin
     if update(lgh_number)  --pts34312 add conditional check
     BEGIN

--PTS37339 begin
     select @tripPakStatus  = coalesce(gi_string1,'DSP,STD,CMP,ICO') from generalinfo where gi_name = 'TMIImageTripStatus'

     if (@tripPakStatus is null or ltrim(@tripPakStatus) = '')
         set @tripPakStatus = 'DSP,STD,CMP,ICO';

     set @tripPakStatus = ',' + @tripPakStatus + ',';

	  Insert into ImageOrderList (ord_hdrnumber)
     Select Distinct ord_hdrnumber
     From stops, inserted
	  Where stops.lgh_number = inserted.lgh_number
	  And stops.ord_hdrnumber > 0 
     And not exists (Select * from ImageOrderList i Where i.ord_hdrnumber = stops.ord_hdrnumber)
     And Exists (Select ord_unit From orderheader Where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 	      and 0 < charindex(',' + orderheader.ord_status + ',', @tripPakStatus))
--PTS37339 end
    END
  END

If Exists (Select gi_string1 from generalinfo where gi_name in( 'ImagingVendorInHouse','ImagingVendorOnRoad')  and gi_string1 in ('TMI','FLYINGJ'))  --pmill 42166/49873 added flyingJ
Begin
	declare @ordcount	int,
			@min		int

	select	@min = min(mov_number)
	  from	inserted	

	while isnull(@min, -1) <> -1
	begin
		select	@ordcount = count(mov_number)
		  from	stops with (nolock) --79330
		 where	mov_number = @min and
				ord_hdrnumber <> 0

		if @ordcount = 0 
		begin
			if (select count(mov_number) from imagemovelist where mov_number = @min) = 0
			begin
				insert into imagemovelist (mov_number) values (@min)
			end
		end
		
		select	@min = min(mov_number)
		  from	inserted
		 where	mov_number > @min
	end
--		 Insert  into ImageMoveList (mov_number)
--		 Select Distinct (mov_number)
--		 From Inserted
--		 Where not exists (Select mov_number From ImageMoveList i Where i.mov_number = inserted.mov_number)
--		 And not exists (Select stp_type From stops s Where s.mov_number = inserted.mov_number and ord_hdrnumber > 0)
End

-- PTS 21890 - DJM - Modified SQL from PTS 18042 to improve performance.  Added to q: and
--	2003 source.
if update(asgn_number) --pts34312 add conditional check
BEGIN
update paydetail
set asgn_number = pydnum.asgn_number
from (select paydetail.pyd_number, inserted.asgn_number
	From Paydetail inner join inserted -- with(index = dk_lghnum),inserted 79441
	on paydetail.lgh_number = inserted.lgh_number
		and paydetail.asgn_id = inserted.asgn_id 
		and paydetail.asgn_type = inserted.asgn_type
		where IsNull(paydetail.asgn_number,0) = 0) pydnum
inner join paydetail pd on pd.pyd_number = pydnum.pyd_number

	-- RE - PTS #62423 BEGIN
	IF EXISTS(SELECT * FROM generalinfo WHERE gi_name = 'VHOS_Interface' AND LEFT(gi_string1,1) = 'Y')
	BEGIN
		INSERT INTO AOS_Tractor_Queue
			(trc_number)
			SELECT	asgn_id
			  FROM	inserted
			 WHERE	asgn_type = 'TRC'
	END
	-- RE - PTS #62423 END
END

--PTS 62529 JJF 20120705
IF  EXISTS	(	SELECT	*
				FROM	generalinfo
				WHERE	gi_name = 'AssignmentPermissions'
						AND gi_string1 = 'Y'
			)  BEGIN
	
	
	exec gettmwuser @tmwuser output
	
	UPDATE	AssignmentPermissons
	SET		ap_active = 'N'
	FROM	inserted i
			LEFT OUTER JOIN deleted d on i.asgn_number = d.asgn_number
	WHERE	ap_userid = @tmwuser
			AND ap_assettype = i.asgn_type
			AND ap_assetid = i.asgn_id
			AND ap_singleuse = 'Y'
			AND i.asgn_id <> ISNULL(d.asgn_id, '')

END
--END PTS 62529 JJF 20120705

GO
ALTER TABLE [dbo].[assetassignment] ADD CONSTRAINT [u_asgnnum] PRIMARY KEY CLUSTERED ([asgn_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AA_DATE_STATUS] ON [dbo].[assetassignment] ([asgn_date], [asgn_status]) INCLUDE ([lgh_number], [asgn_type], [asgn_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AA_ASGN_ID_DATE_STATUS] ON [dbo].[assetassignment] ([asgn_id], [asgn_date], [asgn_status]) INCLUDE ([lgh_number], [asgn_type], [asgn_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_asgn_enddate] ON [dbo].[assetassignment] ([asgn_id], [asgn_type], [asgn_status], [lgh_number], [asgn_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AA_TYPE_DATE_STATUS] ON [dbo].[assetassignment] ([asgn_type], [asgn_date], [asgn_status]) INCLUDE ([lgh_number], [asgn_id], [asgn_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_assetassignment_assetenddate] ON [dbo].[assetassignment] ([asgn_type], [asgn_id], [asgn_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_aa_type_id_leg] ON [dbo].[assetassignment] ([asgn_type], [asgn_id], [lgh_number]) INCLUDE ([pyd_status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_evt_number] ON [dbo].[assetassignment] ([evt_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [assetassignment_INS_TIMESTAMP] ON [dbo].[assetassignment] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d_lghnum] ON [dbo].[assetassignment] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[assetassignment] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_assetassignment_timestamp] ON [dbo].[assetassignment] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[assetassignment] TO [public]
GO
GRANT INSERT ON  [dbo].[assetassignment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[assetassignment] TO [public]
GO
GRANT SELECT ON  [dbo].[assetassignment] TO [public]
GO
GRANT UPDATE ON  [dbo].[assetassignment] TO [public]
GO
