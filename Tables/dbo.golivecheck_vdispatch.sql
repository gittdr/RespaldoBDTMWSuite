CREATE TABLE [dbo].[golivecheck_vdispatch]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_splittrips] [int] NULL,
[glc_cnt_xdock] [int] NULL,
[glc_cnt_mtmoves] [int] NULL,
[glc_pct_moves_with_mtevent] [float] NULL,
[glc_cnt_trlbeams] [int] NULL,
[glc_cnt_tripviews] [int] NULL,
[glc_cnt_resourceviews] [int] NULL,
[glc_chr_setregions] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_pct_org_reg1] [float] NULL,
[glc_cnt_consolidated] [int] NULL,
[glc_pct_prerated] [float] NULL,
[glc_pct_drv_util] [float] NULL,
[glc_pct_trc_util] [float] NULL,
[glc_pct_trl_util] [float] NULL,
[glc_cnt_ord_car_asgn] [int] NULL,
[glc_pct_bad_mileage] [float] NULL,
[glc_cnt_lgh_with_payable] [int] NULL,
[glc_cnt_lgh_no_payable] [int] NULL,
[glc_cnt_upd_by_tmail] [int] NULL,
[glc_cnt_drvbeams] [int] NULL,
[glc_cnt_trcbeams] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_vdispatch] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_vdispatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_vdispatch] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_vdispatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_vdispatch] TO [public]
GO
