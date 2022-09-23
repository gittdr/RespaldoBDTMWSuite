CREATE TABLE [dbo].[TMSOrderXDock]
(
[XDockId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[LocationId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationAltId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCityCode] [int] NULL,
[LocationCityState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationLat] [decimal] (12, 5) NULL,
[LocationLong] [decimal] (12, 5) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderXDock] ADD CONSTRAINT [PK_TMSOrderXDock] PRIMARY KEY CLUSTERED ([XDockId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderXDock] ADD CONSTRAINT [FK_TMSOrderXDock_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderXDock] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderXDock] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderXDock] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderXDock] TO [public]
GO
