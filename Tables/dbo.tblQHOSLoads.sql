CREATE TABLE [dbo].[tblQHOSLoads]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LoadID] [int] NOT NULL,
[LoadTime] [datetime] NOT NULL,
[UnloadTime] [datetime] NOT NULL,
[TrailerIDs] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TractorID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDescriptionType] [int] NOT NULL,
[LoadDescription] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated_on] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQHOSLoads] ADD CONSTRAINT [PK_tblQHOSLoads] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQHOSLoads] ON [dbo].[tblQHOSLoads] ([LoadID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblQHOSLoads] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQHOSLoads] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQHOSLoads] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQHOSLoads] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQHOSLoads] TO [public]
GO
