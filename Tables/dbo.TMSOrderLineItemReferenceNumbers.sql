CREATE TABLE [dbo].[TMSOrderLineItemReferenceNumbers]
(
[ReferenceNumberId] [int] NOT NULL IDENTITY(1, 1),
[LineItemId] [int] NOT NULL,
[OrderId] [int] NOT NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderLineItemReferenceNumbers] ADD CONSTRAINT [PK_TMSOrderLineItemReferenceNumbers] PRIMARY KEY CLUSTERED ([ReferenceNumberId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderLineItemReferenceNumbers] ADD CONSTRAINT [UK_TMSOrderLineItemReferenceNumbers_LineItemId_Type_Text] UNIQUE NONCLUSTERED ([LineItemId], [Type], [Text]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TMSOrderLineItemReferenceNumbers_OrderId] ON [dbo].[TMSOrderLineItemReferenceNumbers] ([OrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderLineItemReferenceNumbers] ADD CONSTRAINT [FK_TMSOrderLineItemReferenceNumbers_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSOrderLineItemReferenceNumbers] ADD CONSTRAINT [FK_TMSOrderLineItemReferenceNumbers_TMSOrderLineItems] FOREIGN KEY ([LineItemId]) REFERENCES [dbo].[TMSOrderLineItems] ([LineItemId])
GO
GRANT DELETE ON  [dbo].[TMSOrderLineItemReferenceNumbers] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderLineItemReferenceNumbers] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderLineItemReferenceNumbers] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderLineItemReferenceNumbers] TO [public]
GO
