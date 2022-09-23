CREATE TABLE [dbo].[edi_856_shipment_notice]
(
[esn_identity] [int] NOT NULL IDENTITY(1, 1),
[esn_tpid] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esn_mb] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esn_bm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esn_po] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esn_cr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esn_tmw] [int] NULL,
[esn_856_tendered] [datetime] NULL,
[esn_856_imported] [datetime] NULL,
[esn_214_received] [datetime] NULL,
[esn_214_warehoused] [datetime] NULL,
[esn_214_delivered] [datetime] NULL,
[esn_skip_trigger] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esn_214_loaded] [datetime] NULL,
[esn_grouping] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_856_shipment_notice] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_856_shipment_notice] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_856_shipment_notice] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_856_shipment_notice] TO [public]
GO
