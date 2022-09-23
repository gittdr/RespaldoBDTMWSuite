CREATE TABLE [dbo].[tariffheaderbid]
(
[timestamp] [timestamp] NULL,
[tar_number] [int] NOT NULL,
[tar_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rowbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_colbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate] [money] NULL,
[tar_incremental] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_nextbreak] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_minquantity] [decimal] (19, 4) NULL,
[tar_mincharge] [money] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_currunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_reduction] [money] NULL,
[tar_reduction_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_createdate] [datetime] NULL,
[tar_updateon] [datetime] NULL,
[tar_applyto_asset] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_rate_override] [money] NULL,
[tar_override_type] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tblratingoption] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tro_roworcolumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_override_pct_alloc_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_totmil_minchg] [money] NULL,
[tar_total_minpay] [money] NULL,
[tar_tax_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_total_minaccpay] [money] NULL,
[tar_standardhours] [decimal] (9, 2) NULL,
[tar_maxquantity] [decimal] (19, 4) NULL,
[tar_maxcharge] [money] NULL,
[tar_proration_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_regional_account_manager] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_rounding] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_event_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_events_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_list] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_compid_inc_excl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_time_calc] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_increment] [decimal] (19, 4) NULL,
[tar_timecalc_free_time] [decimal] (19, 4) NULL,
[tar_BelongsTo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_external_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_external_provider] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_timecalc_free_time_multistop] [decimal] (19, 4) NULL,
[tar_use_bill_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_tarriffnumber] ON [dbo].[tariffheaderbid] ([tar_tarriffnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffheaderbid] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffheaderbid] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffheaderbid] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffheaderbid] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffheaderbid] TO [public]
GO
