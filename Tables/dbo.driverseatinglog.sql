CREATE TABLE [dbo].[driverseatinglog]
(
[dsl_id] [int] NOT NULL IDENTITY(1, 1),
[ds_id] [int] NOT NULL,
[dsl_trc_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dsl_driver1_old] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_driver1_new] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_driver2_old] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_driver2_new] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_driver3_old] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_driver3_new] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsl_seated_dt_old] [datetime] NULL,
[dsl_seated_dt_new] [datetime] NULL,
[dsl_unseated_dt_old] [datetime] NULL,
[dsl_unseated_dt_new] [datetime] NULL,
[dsl_updateddt] [datetime] NOT NULL,
[dsl_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dsl_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverseatinglog] TO [public]
GO
GRANT INSERT ON  [dbo].[driverseatinglog] TO [public]
GO
GRANT SELECT ON  [dbo].[driverseatinglog] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverseatinglog] TO [public]
GO
