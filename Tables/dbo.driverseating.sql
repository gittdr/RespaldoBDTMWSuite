CREATE TABLE [dbo].[driverseating]
(
[ds_id] [int] NOT NULL IDENTITY(1, 1),
[ds_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ds_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ds_driver3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ds_trc_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ds_seated_dt] [datetime] NULL,
[ds_unseated_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driverseating] ADD CONSTRAINT [pk_driverseating_ds_id] PRIMARY KEY CLUSTERED ([ds_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_driverseating_composite] ON [dbo].[driverseating] ([ds_seated_dt], [ds_unseated_dt]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverseating] TO [public]
GO
GRANT INSERT ON  [dbo].[driverseating] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverseating] TO [public]
GO
GRANT SELECT ON  [dbo].[driverseating] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverseating] TO [public]
GO
