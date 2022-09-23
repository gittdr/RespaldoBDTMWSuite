CREATE TABLE [dbo].[nlmpieces]
(
[nlm_shipment_number] [int] NOT NULL,
[nlm_pieces_id] [int] NOT NULL,
[pieces] [int] NULL,
[weight] [int] NULL,
[length] [int] NULL,
[width] [int] NULL,
[height] [int] NULL,
[stackable] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmpieces_id] ON [dbo].[nlmpieces] ([nlm_shipment_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmpieces] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmpieces] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmpieces] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmpieces] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmpieces] TO [public]
GO
