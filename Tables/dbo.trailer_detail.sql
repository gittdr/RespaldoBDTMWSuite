CREATE TABLE [dbo].[trailer_detail]
(
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_det_compartment] [int] NOT NULL,
[trl_det_wet] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_vol] [float] NULL,
[trl_det_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_innage] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_depth] [float] NULL,
[trl_det_ref_pt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_f_bulk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_r_bulk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_chart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_det_depth_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [td_traileridx] ON [dbo].[trailer_detail] ([trl_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_td] ON [dbo].[trailer_detail] ([trl_id], [trl_det_compartment]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailer_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_detail] TO [public]
GO
