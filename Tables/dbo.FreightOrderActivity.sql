CREATE TABLE [dbo].[FreightOrderActivity]
(
[ActivityId] [bigint] NOT NULL IDENTITY(1, 1),
[FreightOrderId] [bigint] NOT NULL,
[FreightActivityId] [smallint] NOT NULL,
[stp_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderActivity] ADD CONSTRAINT [PK_FreightOrderActivity] PRIMARY KEY CLUSTERED ([ActivityId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_FreightOrderId] ON [dbo].[FreightOrderActivity] ([FreightOrderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_stp_number] ON [dbo].[FreightOrderActivity] ([stp_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderActivity] ADD CONSTRAINT [FK_FreightOrderActivity_FreightActivity] FOREIGN KEY ([FreightActivityId]) REFERENCES [dbo].[FreightActivityType] ([FreightActivityId])
GO
ALTER TABLE [dbo].[FreightOrderActivity] ADD CONSTRAINT [FK_FreightOrderActivity_FreightOrder] FOREIGN KEY ([FreightOrderId]) REFERENCES [dbo].[FreightOrder] ([FreightOrderId])
GO
GRANT DELETE ON  [dbo].[FreightOrderActivity] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderActivity] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderActivity] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderActivity] TO [public]
GO
