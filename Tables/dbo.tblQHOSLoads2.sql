CREATE TABLE [dbo].[tblQHOSLoads2]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LoadID] [int] NOT NULL,
[LoadTime] [datetime] NOT NULL,
[DriverID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnloadTime] [datetime] NOT NULL,
[TrailerIDs] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TractorID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDescriptionType] [int] NOT NULL,
[LoadDescription] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQHOSLoads2] ADD CONSTRAINT [PK_tblQHOSLoads2] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQHOSLoads2] ON [dbo].[tblQHOSLoads2] ([LoadID]) ON [PRIMARY]
GO
