CREATE TABLE [dbo].[order_split]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[original_order] [int] NULL,
[split_order] [int] NULL,
[split_id] [int] NULL,
[split_no] [int] NULL,
[is_complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[order_split] ADD CONSTRAINT [PK__order_sp__3213E83F4C8BFF9F] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[order_split] TO [public]
GO
GRANT INSERT ON  [dbo].[order_split] TO [public]
GO
GRANT REFERENCES ON  [dbo].[order_split] TO [public]
GO
GRANT SELECT ON  [dbo].[order_split] TO [public]
GO
GRANT UPDATE ON  [dbo].[order_split] TO [public]
GO
