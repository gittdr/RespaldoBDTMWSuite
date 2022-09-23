CREATE TABLE [dbo].[DriverAwareSuite_Information]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[misc1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extendedopsnotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastviolationdate] [datetime] NULL,
[extdopsnotesdate] [datetime] NULL,
[misc1date] [datetime] NULL,
[completedforday] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_Information] ADD CONSTRAINT [PK_DriverAwareSuite_Information] PRIMARY KEY CLUSTERED ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_Information] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_Information] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_Information] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_Information] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_Information] TO [public]
GO
