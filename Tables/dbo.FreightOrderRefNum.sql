CREATE TABLE [dbo].[FreightOrderRefNum]
(
[FreightOrderRefNumId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[ReferenceType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReferenceValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderRefNum] ADD CONSTRAINT [PK_FreightOrderRefNum] PRIMARY KEY CLUSTERED ([FreightOrderRefNumId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderId] ON [dbo].[FreightOrderRefNum] ([FreightOrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderRefNum] ADD CONSTRAINT [FK_FreightOrderRefNum_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId])
GO
GRANT DELETE ON  [dbo].[FreightOrderRefNum] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderRefNum] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderRefNum] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderRefNum] TO [public]
GO
