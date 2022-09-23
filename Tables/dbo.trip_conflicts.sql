CREATE TABLE [dbo].[trip_conflicts]
(
[mov_number] [int] NOT NULL,
[trc_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_sequence] [smallint] NULL,
[trc_updatedby] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_updateddt] [datetime] NULL,
[trc_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trip_conflicts] ADD CONSTRAINT [PK__trip_conflicts__5987BF39] PRIMARY KEY CLUSTERED ([trc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_mov_number] ON [dbo].[trip_conflicts] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_trc_updateddt] ON [dbo].[trip_conflicts] ([trc_updateddt]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trip_conflicts] TO [public]
GO
GRANT INSERT ON  [dbo].[trip_conflicts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trip_conflicts] TO [public]
GO
GRANT SELECT ON  [dbo].[trip_conflicts] TO [public]
GO
GRANT UPDATE ON  [dbo].[trip_conflicts] TO [public]
GO
