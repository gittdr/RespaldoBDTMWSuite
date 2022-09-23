CREATE TABLE [dbo].[TMSOrderReferenceNumbers]
(
[ReferenceNumberId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderReferenceNumbers] ADD CONSTRAINT [PK_TMSOrderReferenceNumbers] PRIMARY KEY CLUSTERED ([ReferenceNumberId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderReferenceNumbers] ADD CONSTRAINT [FK_TMSOrderReferenceNumbers_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderReferenceNumbers] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderReferenceNumbers] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderReferenceNumbers] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderReferenceNumbers] TO [public]
GO
