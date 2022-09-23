CREATE TABLE [dbo].[ctx_active_legs]
(
[lgh_number] [int] NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[origin_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderby_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderby_cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderby_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_outstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startdate] [datetime] NULL,
[lgh_completiondate] [datetime] NULL,
[lgh_origincity] [int] NULL,
[lgh_destcity] [int] NULL,
[lgh_originstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_deststate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderheader_ord_revtype1_t] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderheader_ord_revtype2_t] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderheader_ord_revtype3_t] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderheader_ord_revtype4_t] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[ord_charge] [money] NULL,
[ord_totalcharge] [float] NULL,
[ord_totalweight] [int] NULL,
[ord_totalpieces] [int] NULL,
[ord_accessorial_chrg] [money] NULL,
[ord_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destregion1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lld_arrivaltime] [datetime] NULL,
[lld_departuretime] [datetime] NULL,
[lld_arrivalstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lld_departurestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lul_arrivaltime] [datetime] NULL,
[lul_departuretime] [datetime] NULL,
[lul_arrivalstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[min_to_arr_lld] [int] NULL,
[min_since_arr_lld] [int] NULL,
[min_to_arr_lul] [int] NULL,
[min_since_arr_lul] [int] NULL,
[min_ckc_to_arr_lul] [int] NULL,
[last_ckc_time] [datetime] NULL,
[min_since_last_ckc] [int] NULL,
[no_response] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_load_origin] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disp_for_pu] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disp_loaded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chryslercmp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[color] [int] NULL,
[firststp] [int] NULL,
[laststp] [int] NULL,
[lul_origarrivalstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordratingunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lld_eta] [datetime] NULL,
[lul_eta] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_lgh_number] ON [dbo].[ctx_active_legs] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ctx_active_legs] TO [public]
GO
GRANT INSERT ON  [dbo].[ctx_active_legs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ctx_active_legs] TO [public]
GO
GRANT SELECT ON  [dbo].[ctx_active_legs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ctx_active_legs] TO [public]
GO
