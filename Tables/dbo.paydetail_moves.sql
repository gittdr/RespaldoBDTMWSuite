CREATE TABLE [dbo].[paydetail_moves]
(
[pyd_number] [int] NOT NULL,
[mov_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetail_moves] ADD CONSTRAINT [pk_paydetail_moves] PRIMARY KEY CLUSTERED ([pyd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetail_moves] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetail_moves] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetail_moves] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetail_moves] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetail_moves] TO [public]
GO
