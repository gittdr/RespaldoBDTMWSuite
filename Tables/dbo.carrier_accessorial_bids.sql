CREATE TABLE [dbo].[carrier_accessorial_bids]
(
[cacb_identity] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[ca_id] [int] NULL,
[cb_id] [int] NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrq_identity] [int] NULL,
[lrq_equip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrp_max_amt] [money] NULL,
[lrp_bid_amt] [money] NULL,
[tsr_number] [int] NULL,
[accessorial_tar_number] [int] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier_accessorial_bids] ADD CONSTRAINT [pk_cacb_identity] PRIMARY KEY CLUSTERED ([cacb_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lrq_identity] ON [dbo].[carrier_accessorial_bids] ([lrq_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[carrier_accessorial_bids] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[carrier_accessorial_bids] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier_accessorial_bids] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier_accessorial_bids] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier_accessorial_bids] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier_accessorial_bids] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier_accessorial_bids] TO [public]
GO
