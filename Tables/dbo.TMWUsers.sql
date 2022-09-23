CREATE TABLE [dbo].[TMWUsers]
(
[UserId] [int] NOT NULL IDENTITY(1, 1),
[ProductId] [int] NOT NULL,
[ProductUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWUsers] ADD CONSTRAINT [PK_UserId] PRIMARY KEY CLUSTERED ([UserId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_TMWUsers_ProductUser_Id] ON [dbo].[TMWUsers] ([ProductUser], [ProductId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWUsers] ADD CONSTRAINT [FK_TMWUsers_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[TMWProducts] ([ProductId])
GO
GRANT DELETE ON  [dbo].[TMWUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWUsers] TO [public]
GO
