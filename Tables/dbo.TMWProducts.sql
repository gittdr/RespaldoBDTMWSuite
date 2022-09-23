CREATE TABLE [dbo].[TMWProducts]
(
[ProductId] [int] NOT NULL,
[ProductName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWProducts] ADD CONSTRAINT [PK_ProductId] PRIMARY KEY CLUSTERED ([ProductId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWProducts] ADD CONSTRAINT [UQ__TMWProdu__B40CC6CC3BA621C8] UNIQUE NONCLUSTERED ([ProductId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWProducts] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWProducts] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWProducts] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWProducts] TO [public]
GO
