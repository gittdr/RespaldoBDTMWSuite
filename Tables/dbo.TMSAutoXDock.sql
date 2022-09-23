CREATE TABLE [dbo].[TMSAutoXDock]
(
[AutoXDockID] [int] NOT NULL IDENTITY(1, 1),
[LaneID] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[CompanyID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AvgXDockHours] [decimal] (18, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAutoXDock] ADD CONSTRAINT [PK_TMSAutoXDock] PRIMARY KEY CLUSTERED ([AutoXDockID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAutoXDock] ADD CONSTRAINT [IX_TMSAutoXDock] UNIQUE NONCLUSTERED ([LaneID], [Sequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAutoXDock] ADD CONSTRAINT [FK_TMSAutoXDock_TMSLaneHeader] FOREIGN KEY ([LaneID]) REFERENCES [dbo].[TMSLaneHeader] ([LaneID])
GO
GRANT DELETE ON  [dbo].[TMSAutoXDock] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSAutoXDock] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSAutoXDock] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSAutoXDock] TO [public]
GO
