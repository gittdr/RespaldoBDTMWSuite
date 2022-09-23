CREATE TABLE [dbo].[tractor_detail]
(
[trc_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_det_compartment] [int] NOT NULL,
[trc_det_wet] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_vol] [float] NULL,
[trc_det_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_innage] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_depth] [float] NULL,
[trc_det_ref_pt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_f_bulk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_r_bulk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_chart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_det_depth_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tractor_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[tractor_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tractor_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[tractor_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[tractor_detail] TO [public]
GO
