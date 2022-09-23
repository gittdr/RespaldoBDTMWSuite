CREATE TABLE [dbo].[edi_856_shipment_details]
(
[esd_identity] [int] NOT NULL IDENTITY(1, 1),
[esh_identity] [int] NOT NULL,
[esh_bm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esd_cmd] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esd_ls] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esd_wh] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esd_description] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esd_quantity] [int] NULL,
[esd_rcvd_overage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_r__10226228] DEFAULT ((0)),
[esd_rcvd_shortage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_r__11168661] DEFAULT ((0)),
[esd_rcvd_damage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_r__120AAA9A] DEFAULT ((0)),
[esd_whse_overage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_w__12FECED3] DEFAULT ((0)),
[esd_whse_shortage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_w__13F2F30C] DEFAULT ((0)),
[esd_whse_damage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_w__14E71745] DEFAULT ((0)),
[esd_dlvr_overage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_d__15DB3B7E] DEFAULT ((0)),
[esd_dlvr_shortage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_d__16CF5FB7] DEFAULT ((0)),
[esd_dlvr_damage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_d__17C383F0] DEFAULT ((0)),
[esd_load_overage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_l__4E2D1568] DEFAULT ((0)),
[esd_load_shortage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_l__4F2139A1] DEFAULT ((0)),
[esd_load_damage] [int] NOT NULL CONSTRAINT [DF__edi_856_s__esd_l__50155DDA] DEFAULT ((0)),
[esd_comment] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_856_shipment_details] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_856_shipment_details] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_856_shipment_details] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_856_shipment_details] TO [public]
GO
