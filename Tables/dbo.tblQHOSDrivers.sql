CREATE TABLE [dbo].[tblQHOSDrivers]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DriverID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverGroup] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WeekCycle] [int] NOT NULL,
[DepotID] [int] NULL,
[Retired] [int] NULL,
[updated_on] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQHOSDrivers] ADD CONSTRAINT [PK_tblQHOSDrivers] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQHOSDrivers] ON [dbo].[tblQHOSDrivers] ([DriverID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblQHOSDrivers] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQHOSDrivers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQHOSDrivers] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQHOSDrivers] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQHOSDrivers] TO [public]
GO
