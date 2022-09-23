CREATE TABLE [dbo].[ImageOrderList]
(
[iol_ID] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageOrderList] ADD CONSTRAINT [PK__ImageOrderList__5E218BCD] PRIMARY KEY CLUSTERED ([iol_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ordhdrnumber] ON [dbo].[ImageOrderList] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageOrderList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageOrderList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageOrderList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageOrderList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageOrderList] TO [public]
GO
