CREATE TABLE [dbo].[TMSOrderEq]
(
[EqId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[EqCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMSOrderEq_EqCode] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderEq] ADD CONSTRAINT [PK_TMSOrderEq] PRIMARY KEY CLUSTERED ([EqId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderEq] ADD CONSTRAINT [fk_tmsordereq_oid] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderEq] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderEq] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderEq] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderEq] TO [public]
GO
