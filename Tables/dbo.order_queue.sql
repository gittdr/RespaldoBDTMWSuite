CREATE TABLE [dbo].[order_queue]
(
[id] [numeric] (18, 0) NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[timestamp] [timestamp] NOT NULL,
[processing_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[order_queue] TO [public]
GO
GRANT INSERT ON  [dbo].[order_queue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[order_queue] TO [public]
GO
GRANT SELECT ON  [dbo].[order_queue] TO [public]
GO
GRANT UPDATE ON  [dbo].[order_queue] TO [public]
GO
