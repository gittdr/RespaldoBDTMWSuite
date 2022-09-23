CREATE TABLE [dbo].[TMSOrderAccessorials]
(
[AccId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[Quantity] [decimal] (12, 4) NOT NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderAccessorials] ADD CONSTRAINT [PK_TMSOrderAccessorials] PRIMARY KEY CLUSTERED ([AccId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderAccessorials] ADD CONSTRAINT [FK_TMSOrderAccessorials_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderAccessorials] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderAccessorials] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderAccessorials] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderAccessorials] TO [public]
GO
