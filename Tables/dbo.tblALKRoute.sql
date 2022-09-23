CREATE TABLE [dbo].[tblALKRoute]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LocationName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PointRadius] [int] NULL,
[Distance] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Master] [bit] NOT NULL,
[RollingTime] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblALKRoute] ADD CONSTRAINT [PK_tblALKRoute] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblALKRoute_LocationName_D]', N'[dbo].[tblALKRoute].[LocationName]'
GO
EXEC sp_bindefault N'[dbo].[tblALKRoute_Latitude_D]', N'[dbo].[tblALKRoute].[Latitude]'
GO
EXEC sp_bindefault N'[dbo].[tblALKRoute_Longitude_D]', N'[dbo].[tblALKRoute].[Longitude]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblALKRoute].[PointRadius]'
GO
EXEC sp_bindefault N'[dbo].[tblALKRoute_Distance_D]', N'[dbo].[tblALKRoute].[Distance]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblALKRoute].[Master]'
GO
EXEC sp_bindefault N'[dbo].[tblALKRoute_RollingTime_D]', N'[dbo].[tblALKRoute].[RollingTime]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblALKRoute].[Sequence]'
GO
GRANT DELETE ON  [dbo].[tblALKRoute] TO [public]
GO
GRANT INSERT ON  [dbo].[tblALKRoute] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblALKRoute] TO [public]
GO
GRANT SELECT ON  [dbo].[tblALKRoute] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblALKRoute] TO [public]
GO
