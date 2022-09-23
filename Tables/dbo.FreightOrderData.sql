CREATE TABLE [dbo].[FreightOrderData]
(
[FreightOrderDataId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[ClassificationId] [smallint] NOT NULL,
[Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderData] ADD CONSTRAINT [PK_FreightOrderData] PRIMARY KEY CLUSTERED ([FreightOrderDataId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ClassificationId_Value] ON [dbo].[FreightOrderData] ([ClassificationId], [Value]) INCLUDE ([FreightOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderId] ON [dbo].[FreightOrderData] ([FreightOrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderData] ADD CONSTRAINT [FK_FreightOrderClassification_ClassificationType] FOREIGN KEY ([ClassificationId]) REFERENCES [dbo].[ClassificationType] ([ClassificationId])
GO
ALTER TABLE [dbo].[FreightOrderData] ADD CONSTRAINT [FK_FreightOrderClassification_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId])
GO
GRANT DELETE ON  [dbo].[FreightOrderData] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderData] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderData] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderData] TO [public]
GO
