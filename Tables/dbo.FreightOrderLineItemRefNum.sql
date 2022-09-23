CREATE TABLE [dbo].[FreightOrderLineItemRefNum]
(
[FreightOrderLineItemRefNumId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderLineItemId] [bigint] NOT NULL,
[ReferenceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferenceValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderLineItemRefNum] ADD CONSTRAINT [PK_FreightOrderLineItemRefNum] PRIMARY KEY CLUSTERED ([FreightOrderLineItemRefNumId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderLineItemRefNumId] ON [dbo].[FreightOrderLineItemRefNum] ([FreightOrderLineItemId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderLineItemRefNum] ADD CONSTRAINT [FK_FreightOrderLineItemRefNum_FreightOrderLineItem] FOREIGN KEY ([FreightOrderLineItemId]) REFERENCES [dbo].[FreightOrderLineItem] ([FreightOrderLineItemId])
GO
GRANT DELETE ON  [dbo].[FreightOrderLineItemRefNum] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderLineItemRefNum] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderLineItemRefNum] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderLineItemRefNum] TO [public]
GO
