CREATE TABLE [dbo].[tractoraccesories]
(
[tca_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tca_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tca_cost] [float] NULL,
[tca_hours] [int] NULL,
[tca_dateaquired] [datetime] NULL,
[tca_opercost] [float] NULL,
[tca_fueltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tca_tractor] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL,
[tca_quantitiy] [int] NULL,
[tca_expire_date] [datetime] NOT NULL,
[tca_expire_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tca_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tractoraccessory_id] [int] NOT NULL IDENTITY(1, 1),
[tca_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tca_value] [decimal] (10, 2) NULL,
[tca_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__tractorac__INS_T__7B9B0B16] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATIONS

-- 8/8/2006 PTS 33485 BDH - Added tca_source column to tractoraccesories to distinguish between tractors and carrier tractors.

*/


CREATE TRIGGER [dbo].[dt_tractoraccessories] ON [dbo].[tractoraccesories]
FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	@tractor	varchar(12)

begin	
   SELECT @nextaccessory = '',
	  @accessorylist = ''

   SELECT @tractor = min(tca_tractor) from deleted







   WHILE 1=1
   BEGIN
	SELECT @nextaccessory = min(tca_type)
	FROM	tractoraccesories
	WHERE	tca_type > @nextaccessory AND
		tca_tractor = @tractor AND
		tca_type NOT IN (SELECT tca_type
				from deleted)
		-- 33485 BDH (start)
		and upper(tca_source) = 'TRC'
		-- 33485 BDH (end)

	If @nextaccessory is null BREAK
	SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
   END


SELECT @accessorylist = @accessorylist + ',,'

If @accessorylist = ',,' or @accessorylist = ',,,,'
   UPDATE tractorprofile
   SET	  trc_accessorylist = ''
   FROM	  DELETED
   WHERE  deleted.tca_tractor = tractorprofile.trc_number
ELSE
   UPDATE tractorprofile
   SET	  trc_accessorylist = @accessorylist
   FROM	  DELETED
   WHERE  deleted.tca_tractor = tractorprofile.trc_number
	  
end 

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATIONS

-- 8/8/2006 PTS 33485 BDH - Added tca_source column to tractoraccesories to distinguish between tractors and carrier tractors.

*/

CREATE TRIGGER [dbo].[iut_tractoraccessories] ON [dbo].[tractoraccesories]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	@tractor	varchar(12)

begin	
   SELECT @nextaccessory = '',
	  @accessorylist = ''

   SELECT @tractor = min(tca_tractor) from inserted

   WHILE 1=1
   BEGIN
	SELECT @nextaccessory = min(tca_type)
	FROM	tractoraccesories
	WHERE	tca_type > @nextaccessory AND
		tca_tractor = @tractor
-- PTS 18488 -- BL (start)
	and tca_expire_date >= getdate()
-- PTS 18488 -- BL (end)
-- PTS 33485 BDH (start)
	and upper(tca_source) = 'TRC'
-- PTS 33485 BDH (end)

	If @nextaccessory is null BREAK
	SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
   END


SELECT @accessorylist = @accessorylist + ',,'

UPDATE tractorprofile
SET	trc_accessorylist = @accessorylist
FROM	inserted
WHERE	inserted.tca_tractor = tractorprofile.trc_number AND
	@accessorylist <> IsNull(trc_accessorylist, '')
	  
end 


GO
ALTER TABLE [dbo].[tractoraccesories] ADD CONSTRAINT [pk_tractoraccesories] PRIMARY KEY CLUSTERED ([tractoraccessory_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tractoraccesories_INS_TIMESTAMP] ON [dbo].[tractoraccesories] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_tca_type] ON [dbo].[tractoraccesories] ([tca_type], [tca_tractor], [tca_source]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tractoraccesories] TO [public]
GO
GRANT INSERT ON  [dbo].[tractoraccesories] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tractoraccesories] TO [public]
GO
GRANT SELECT ON  [dbo].[tractoraccesories] TO [public]
GO
GRANT UPDATE ON  [dbo].[tractoraccesories] TO [public]
GO
