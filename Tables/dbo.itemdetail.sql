CREATE TABLE [dbo].[itemdetail]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[order_hdrnumber] [int] NULL,
[fgt_number] [int] NULL,
[item_id] [int] NULL,
[item_barcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_barcode1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alt_barcode2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comments] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_count] [decimal] (10, 2) NULL,
[item_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_pallet] [float] NULL,
[item_palletunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_weight] [float] NULL,
[item_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_volume] [float] NULL,
[item_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_length] [float] NULL,
[item_lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_height] [float] NULL,
[item_heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_width] [float] NULL,
[item_widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[org_order_hdrnumber] [int] NULL,
[org_fgt_number] [int] NULL,
[rowchgts] [timestamp] NOT NULL,
[location_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[position] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[itemdetail] ADD CONSTRAINT [PK__itemdeta__3213E83F41DB7E3E] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[itemdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[itemdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[itemdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[itemdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[itemdetail] TO [public]
GO
