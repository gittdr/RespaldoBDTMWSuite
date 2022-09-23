CREATE TABLE [dbo].[TMSServiceOptions]
(
[ServiceOptionID] [int] NOT NULL IDENTITY(1, 1),
[LaneID] [int] NOT NULL,
[Mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Days] [decimal] (18, 2) NULL,
[Carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSServiceOptions] ADD CONSTRAINT [PK_TMSServiceOptions] PRIMARY KEY CLUSTERED ([ServiceOptionID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSServiceOptions] ADD CONSTRAINT [FK_TMSServiceOptions_TMSLaneHeader] FOREIGN KEY ([LaneID]) REFERENCES [dbo].[TMSLaneHeader] ([LaneID])
GO
GRANT DELETE ON  [dbo].[TMSServiceOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSServiceOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSServiceOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSServiceOptions] TO [public]
GO
