CREATE TABLE [dbo].[TMSStopReferenceNumbers]
(
[ReferenceNumberId] [int] NOT NULL IDENTITY(1, 1),
[StopId] [int] NOT NULL,
[OrderId] [int] NOT NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStopReferenceNumbers] ADD CONSTRAINT [PK_TMSStopReferenceNumbers] PRIMARY KEY CLUSTERED ([ReferenceNumberId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TMSStopReferenceNumbers_OrderId] ON [dbo].[TMSStopReferenceNumbers] ([OrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStopReferenceNumbers] ADD CONSTRAINT [UK_TMSStopReferenceNumbers_StopId_Type_Text] UNIQUE NONCLUSTERED ([StopId], [Type], [Text]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStopReferenceNumbers] ADD CONSTRAINT [FK_TMSStopReferenceNumbers_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSStopReferenceNumbers] ADD CONSTRAINT [FK_TMSStopReferenceNumbers_TMSStops] FOREIGN KEY ([StopId]) REFERENCES [dbo].[TMSStops] ([StopId])
GO
GRANT DELETE ON  [dbo].[TMSStopReferenceNumbers] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStopReferenceNumbers] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStopReferenceNumbers] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStopReferenceNumbers] TO [public]
GO
