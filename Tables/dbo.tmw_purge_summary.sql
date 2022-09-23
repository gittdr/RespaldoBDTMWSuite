CREATE TABLE [dbo].[tmw_purge_summary]
(
[pur_id] [int] NOT NULL IDENTITY(1, 1),
[pur_run_date] [datetime] NULL CONSTRAINT [DF__tmw_purge__pur_r__175E01DC] DEFAULT (getdate()),
[pur_status] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pur_mov_count] [int] NULL,
[pur_order_count] [int] NULL,
[pur_legheader_count] [int] NULL,
[pur_stops_count] [int] NULL,
[pur_assetassignment_count] [int] NULL,
[pur_inv_count] [int] NULL,
[pur_pay_count] [int] NULL,
[pur_pay_hdr_count] [int] NULL,
[pur_extra_info_data_count] [int] NULL,
[pur_chargetype_audit_count] [int] NULL,
[pur_disp_audit_count] [int] NULL,
[pur_expidite_audit_count] [int] NULL,
[pur_invoicedetail_audit_count] [int] NULL,
[pur_paydetail_audit_count] [int] NULL,
[pur_paytype_audit_count] [int] NULL,
[pur_trip_audit_count] [int] NULL,
[pur_orderheader_cancel_log_count] [int] NULL,
[pur_tarifferrorlog_count] [int] NULL,
[pur_tts_errorlog_count] [int] NULL,
[pur_log_driverlogs_count] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmw_purge_summary] ADD CONSTRAINT [PK__tmw_purge_summar__1669DDA3] PRIMARY KEY CLUSTERED ([pur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_purge_summary] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_purge_summary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmw_purge_summary] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_purge_summary] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_purge_summary] TO [public]
GO
