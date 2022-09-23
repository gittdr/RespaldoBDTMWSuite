CREATE TABLE [dbo].[invoicebatch]
(
[ivb_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivb_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivb_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ivb_id] ON [dbo].[invoicebatch] ([ivb_id], [ivb_revtype4]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoicebatch] TO [public]
GO
GRANT INSERT ON  [dbo].[invoicebatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoicebatch] TO [public]
GO
GRANT SELECT ON  [dbo].[invoicebatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoicebatch] TO [public]
GO
