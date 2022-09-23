CREATE TABLE [dbo].[TareLog]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[tl_RecordType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_stp_number] [int] NULL,
[tl_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_order_qty] [decimal] (18, 0) NULL,
[tl_order_qty_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_datetime] [datetime] NULL,
[tl_trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_trl_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_trl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_mpp_id1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_mpp_id2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_fromdriver_gross_wgt] [decimal] (18, 0) NULL,
[tl_fromdriver_gross_wgt_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_fromdriver_qty] [decimal] (18, 0) NULL,
[tl_fromdriver_qtyUOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_fromdriver_ConvertedToWeight] [decimal] (18, 0) NULL,
[tl_fromdriver_ConvertedToWeight_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_fuel_gallons] [int] NULL,
[tl_fuel_wgt] [decimal] (18, 0) NULL,
[tl_fuel_wgt_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_variance] [decimal] (18, 0) NULL,
[tl_variance_percent] [float] NULL,
[tl_trctrl_gross_wgt] [int] NULL,
[tl_optimum_wgt] [int] NULL,
[tl_optimum_wgt_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_country] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tl_ResultStatus] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [TareLog_PK] ON [dbo].[TareLog] ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TareLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TareLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TareLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TareLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TareLog] TO [public]
GO
