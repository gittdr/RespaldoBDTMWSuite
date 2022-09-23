CREATE TABLE [dbo].[tblQHOSTractors]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Alias] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DepotID] [int] NULL,
[TractorID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleGroup] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_on] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQHOSTractors] ADD CONSTRAINT [PK_tblQHOSTractors] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQHOSTractors] ON [dbo].[tblQHOSTractors] ([TractorID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblQHOSTractors] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQHOSTractors] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQHOSTractors] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQHOSTractors] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQHOSTractors] TO [public]
GO
