CREATE TABLE [dbo].[preplan_assets]
(
[ppa_id] [int] NOT NULL,
[ppa_lgh_number] [int] NOT NULL,
[ppa_mov_number] [int] NOT NULL,
[ppa_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_createdon] [datetime] NOT NULL,
[ppa_status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ppa_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ppa_chassis] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_chassis] DEFAULT ('UNKNOWN'),
[ppa_chassis2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_chassis2] DEFAULT ('UNKNOWN'),
[ppa_dolly] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_dolly] DEFAULT ('UNKNOWN'),
[ppa_dolly2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_dolly2] DEFAULT ('UNKNOWN'),
[ppa_trailer3] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_trailer3] DEFAULT ('UNKNOWN'),
[ppa_trailer4] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_ppa_trailer4] DEFAULT ('UNKNOWN')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_preplan_assets] ON [dbo].[preplan_assets] FOR DELETE  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
DECLARE @tractor_id varchar(8)

SELECT	@tractor_id = deleted.ppa_tractor
FROM	deleted
EXEC	trc_expstatus @tractor_id


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[it_preplan_assets] ON [dbo].[preplan_assets] FOR INSERT  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 


DECLARE @ord int,
		@mov_number int,
		@tractor_id varchar(8),
		@ls_audit	varchar(1)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT 	@tractor_id = inserted.ppa_tractor
FROM	inserted
EXEC	trc_expstatus @tractor_id

--vmj1+
select	@ls_audit = isnull(upper(substring(g1.gi_string1, 1, 1)), 'N')
  from	generalinfo g1
  where	g1.gi_name = 'FingerprintAudit'
	and	g1.gi_datein = (select	max(g2.gi_datein)
						  from	generalinfo g2
						  where	g2.gi_name = 'FingerprintAudit'
							and	g2.gi_datein <= getdate())
if @ls_audit = 'Y'
--IF (select upper(substring(gi_string1,1,1)) FROM generalinfo
--       WHERE gi_name = 'FingerprintAudit') = 'Y'
--vmj1-
BEGIN
	SELECT 	@mov_number = inserted.ppa_mov_number,
    		@tractor_id = ppa_tractor
      FROM 	inserted

	--PTS 46812 CGK 4/16/2009 Does not work for Cross Dock Trips
     --set @ord = (SELECT Min(ord_hdrnumber) FROM orderheader WHERE mov_number = @mov_number)
	set @ord = (SELECT Min(ord_hdrnumber) FROM stops WHERE mov_number = @mov_number and ord_hdrnumber > 0)

   	insert into expedite_audit 
			(ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity,
			--vmj1+	PTS 12286	02/28/2002	Clarify that this is Multi-Plan status..
			update_note
			--vmj1-
			)
	  values (@ord, 
			UPPER(@tmwuser), 
			GETDATE(), 
			'PB' + @tractor_id,
			--vmj1+
			'Multi-Planned ' + @tractor_id
			--vmj1-
			)
END


/* Updates preplan_assets 'ppa_createdon' to getdate() */
UPDATE	preplan_assets 
   SET	ppa_createdon = GetDate()
  FROM	preplan_assets, inserted 

 WHERE	preplan_assets.ppa_id = inserted.ppa_id

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_preplan_assets] ON [dbo].[preplan_assets] FOR UPDATE  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
      declare @ord int,
                 @mov_number int,
                 @tractor_id varchar(8),
                 @status varchar(20),
	   @minid int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT	@tractor_id = inserted.ppa_tractor
FROM	inserted
EXEC	trc_expstatus @tractor_id

SELECT	@tractor_id = deleted.ppa_tractor
FROM	deleted
EXEC	trc_expstatus @tractor_id

IF UPDATE(ppa_status)
BEGIN
   IF (SELECT upper(substring(gi_string1,1,1)) FROM generalinfo
        WHERE gi_name = 'FingerprintAudit') = 'Y'
   BEGIN
      SELECT @minid = 0
      WHILE ( SELECT COUNT(*) 
                       FROM inserted
	      WHERE ppa_id > @minid ) > 0
      BEGIN
         SELECT @minid = MIN ( ppa_id ) 
            FROM inserted
         WHERE ppa_id > @minid
         SELECT @mov_number = inserted.ppa_mov_number,
                      @tractor_id = inserted.ppa_tractor,
                      @status = inserted.ppa_status
            FROM inserted
           WHERE inserted.ppa_id = @minid
         if @status = 'No Response'
         BEGIN
			--PTS 46812 CGK 4/16/2009 Does not work for Cross Dock Trips
            --set @ord = (SELECT Min(ord_hdrnumber) FROM orderheader WHERE mov_number = @mov_number)
			set @ord = (SELECT Min(ord_hdrnumber) FROM stops WHERE mov_number = @mov_number and ord_hdrnumber > 0)

            insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
                                     values   (@ord, UPPER(@tmwuser), GETDATE(), 'VB' + @tractor_id)
         END
      END
   END
END



GO
ALTER TABLE [dbo].[preplan_assets] ADD CONSTRAINT [pk_ppa_id] PRIMARY KEY CLUSTERED ([ppa_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrier] ON [dbo].[preplan_assets] ([ppa_carrier]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_driver1] ON [dbo].[preplan_assets] ([ppa_driver1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_driver2] ON [dbo].[preplan_assets] ([ppa_driver2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lgh_number] ON [dbo].[preplan_assets] ([ppa_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[preplan_assets] ([ppa_mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tractor] ON [dbo].[preplan_assets] ([ppa_tractor]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trailer1] ON [dbo].[preplan_assets] ([ppa_trailer1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trailer2] ON [dbo].[preplan_assets] ([ppa_trailer2]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[preplan_assets] TO [public]
GO
GRANT INSERT ON  [dbo].[preplan_assets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[preplan_assets] TO [public]
GO
GRANT SELECT ON  [dbo].[preplan_assets] TO [public]
GO
GRANT UPDATE ON  [dbo].[preplan_assets] TO [public]
GO
