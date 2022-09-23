CREATE TABLE [dbo].[edi_trading_partner]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_alias] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_linehaulmax] [money] NULL,
[trp_totchargemax] [money] NULL,
[trp_NxtCtlNbr] [int] NULL,
[trp_storenumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_storenumbertype] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_ckcall_interval] [int] NULL,
[trp_210ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214ExportNotes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214ISAID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210ISAID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210ExportNotes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_shp_cn_donotsend_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214Save] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210Save] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_export_210_stopdates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_long_storecodes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_cityst] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_pupwgt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_prevent_early_pup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_prevent_early_pup_min] [smallint] NULL,
[trp_214_prevent_early_pup_adj] [smallint] NULL,
[trp_214_aceinfo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_stopoff_details] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_fgt_supplier] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_splc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_pupwgt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_pod] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_multiStopRefFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_multiStopRefType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_etaDate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_apptDates] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_210_restrictTerms] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_214_restrictTerms] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmp_id] ON [dbo].[edi_trading_partner] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_trading_partner] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_trading_partner] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_trading_partner] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_trading_partner] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_trading_partner] TO [public]
GO
