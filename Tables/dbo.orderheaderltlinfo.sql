CREATE TABLE [dbo].[orderheaderltlinfo]
(
[ord_hdrnumber] [int] NOT NULL,
[pickup_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_apmt_required] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_apmt_required] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_apmt_made] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_apmt_made] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[has_notes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__orderhead__has_n__72058928] DEFAULT ('N'),
[hazmat] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__orderhead__hazma__72F9AD61] DEFAULT ('N'),
[temperature_control] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__orderhead__tempe__73EDD19A] DEFAULT ('N'),
[status_ts] [datetime] NULL,
[ord_contact_phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_ins_pick] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_ins_del] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship_ins_oth] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_client] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_client_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[net_charges] [money] NULL,
[protected_charges] [money] NULL,
[carrier_charges] [money] NULL,
[ref_ord_hdrnumber] [int] NULL CONSTRAINT [DF__orderhead__ref_o__74E1F5D3] DEFAULT ((0)),
[pro_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__orderhead__pro_t__75D61A0C] DEFAULT ('SHP'),
[signature_image] [image] NULL,
[quote_expiration] [datetime] NULL,
[quote_max_uses] [int] NULL,
[quote_times_used] [int] NULL,
[pickup_distance] [decimal] (10, 2) NULL,
[delivery_distance] [decimal] (10, 2) NULL,
[pickup_terminal_transfer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_terminal_transfer] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup_number] [int] NULL,
[con_id] [int] NULL,
[delivery_number] [int] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__orderhead__INS_T__64B7A5BE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[orderheaderltlinfo] ADD CONSTRAINT [PK__orderhea__68673FEF435F2F00] PRIMARY KEY CLUSTERED ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ohltl_delv_term] ON [dbo].[orderheaderltlinfo] ([delivery_terminal], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [orderheaderltlinfo_INS_TIMESTAMP] ON [dbo].[orderheaderltlinfo] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ohltl_pick_term] ON [dbo].[orderheaderltlinfo] ([pickup_terminal], [ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[orderheaderltlinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[orderheaderltlinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[orderheaderltlinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[orderheaderltlinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[orderheaderltlinfo] TO [public]
GO
