CREATE TABLE [dbo].[KaneDistributors]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[KaneId] [int] NOT NULL,
[AllAuthors] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Address2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mileage] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryCarrier] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SecondaryCarrier] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C5DISTSPR] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Zip] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SCAC] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C5TSTP] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneDistributors] ADD CONSTRAINT [PK_KaneDistributors] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneDistributors] ADD CONSTRAINT [FK_KaneDistributors_KaneBatch] FOREIGN KEY ([KaneId]) REFERENCES [dbo].[KaneBatch] ([KaneId])
GO
GRANT DELETE ON  [dbo].[KaneDistributors] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneDistributors] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneDistributors] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneDistributors] TO [public]
GO
