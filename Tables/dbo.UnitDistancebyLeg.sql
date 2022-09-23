CREATE TABLE [dbo].[UnitDistancebyLeg]
(
[udl_ID] [int] NOT NULL IDENTITY(1, 1),
[udl_unittype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[udl_unitid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[udl_lgh_number] [int] NOT NULL,
[udl_distance] [decimal] (8, 1) NOT NULL,
[udl_start_date] [datetime] NOT NULL,
[udl_last_updated] [datetime] NULL,
[udl_last_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[udl_stlstatus] [tinyint] NOT NULL,
[udl_verified] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitDistancebyLeg] ADD CONSTRAINT [pk_UnitDistancebyLeg] PRIMARY KEY CLUSTERED ([udl_unittype], [udl_unitid], [udl_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_UnitDistancebyLeg_lghnumber] ON [dbo].[UnitDistancebyLeg] ([udl_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_UnitDistancebyLeg_startdate] ON [dbo].[UnitDistancebyLeg] ([udl_start_date], [udl_unitid], [udl_unittype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UnitDistancebyLeg] TO [public]
GO
GRANT INSERT ON  [dbo].[UnitDistancebyLeg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[UnitDistancebyLeg] TO [public]
GO
GRANT SELECT ON  [dbo].[UnitDistancebyLeg] TO [public]
GO
GRANT UPDATE ON  [dbo].[UnitDistancebyLeg] TO [public]
GO
