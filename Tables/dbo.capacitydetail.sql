CREATE TABLE [dbo].[capacitydetail]
(
[cpd_number] [int] NOT NULL IDENTITY(1, 1),
[cph_number] [int] NULL,
[cpd_seq] [int] NULL,
[cpd_weight] [decimal] (12, 4) NULL,
[cpd_loadingmeters] [decimal] (10, 2) NULL,
[cpd_volume] [decimal] (10, 4) NULL,
[cpd_calcweight] [decimal] (12, 4) NULL,
[cpd_wgt_empty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_ldm_empty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_vol_empty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_calcwgt_emtpy] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_red] [int] NULL,
[cpd_green] [int] NULL,
[cpd_blue] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[capacitydetail] TO [public]
GO
GRANT INSERT ON  [dbo].[capacitydetail] TO [public]
GO
GRANT SELECT ON  [dbo].[capacitydetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[capacitydetail] TO [public]
GO
