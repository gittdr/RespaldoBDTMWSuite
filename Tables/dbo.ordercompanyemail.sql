CREATE TABLE [dbo].[ordercompanyemail]
(
[ord_hdrnumber] [int] NOT NULL,
[ce_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordercompanyemail] ADD CONSTRAINT [PK_ordercompanyemail] PRIMARY KEY CLUSTERED ([ord_hdrnumber], [ce_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordercompanyemail] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercompanyemail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercompanyemail] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercompanyemail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercompanyemail] TO [public]
GO
