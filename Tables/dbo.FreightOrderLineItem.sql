CREATE TABLE [dbo].[FreightOrderLineItem]
(
[FreightOrderLineItemId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[ProductCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderLineItem] ADD CONSTRAINT [PK_FreightOrderLineItem] PRIMARY KEY CLUSTERED ([FreightOrderLineItemId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderId] ON [dbo].[FreightOrderLineItem] ([FreightOrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderLineItem] ADD CONSTRAINT [FK_FreightOrderLineItem_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId])
GO
GRANT DELETE ON  [dbo].[FreightOrderLineItem] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderLineItem] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderLineItem] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderLineItem] TO [public]
GO
