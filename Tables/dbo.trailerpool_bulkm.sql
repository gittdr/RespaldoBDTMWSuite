CREATE TABLE [dbo].[trailerpool_bulkm]
(
[pol_trailer_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pol_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pol_pool] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pol_days_at] [int] NULL,
[pol_arrival_date] [datetime] NOT NULL,
[pol_depart_date] [datetime] NOT NULL,
[pol_last_update] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pol_pool] ON [dbo].[trailerpool_bulkm] ([pol_pool]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pol_terminal] ON [dbo].[trailerpool_bulkm] ([pol_terminal]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pol_trailer_id] ON [dbo].[trailerpool_bulkm] ([pol_trailer_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailerpool_bulkm] TO [public]
GO
GRANT INSERT ON  [dbo].[trailerpool_bulkm] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailerpool_bulkm] TO [public]
GO
GRANT SELECT ON  [dbo].[trailerpool_bulkm] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailerpool_bulkm] TO [public]
GO
