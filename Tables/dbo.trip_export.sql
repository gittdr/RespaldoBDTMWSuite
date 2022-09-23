CREATE TABLE [dbo].[trip_export]
(
[systemnum] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_num] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_date] [datetime] NULL,
[ord_origin_earliestdate] [datetime] NULL,
[dealer_num] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dealer_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_sequence] [int] NULL,
[pl_arr_tm] [datetime] NULL,
[act_arr_tm] [datetime] NULL,
[pl_dpt_tm] [datetime] NULL,
[act_dpt_tm] [datetime] NULL,
[arr_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arr_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arr_code] [int] NULL,
[dpt_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dpt_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dpt_code] [int] NULL,
[ord_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unld_tol] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arr_tol] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkcall] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[special] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[del] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NOT NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NOT NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_refnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_batch_number] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trip_export] TO [public]
GO
GRANT INSERT ON  [dbo].[trip_export] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trip_export] TO [public]
GO
GRANT SELECT ON  [dbo].[trip_export] TO [public]
GO
GRANT UPDATE ON  [dbo].[trip_export] TO [public]
GO
