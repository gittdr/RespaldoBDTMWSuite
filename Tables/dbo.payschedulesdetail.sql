CREATE TABLE [dbo].[payschedulesdetail]
(
[psd_id] [int] NOT NULL,
[psd_date] [datetime] NULL,
[psd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_id] [int] NOT NULL,
[psd_batch_id] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_batch_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_chkissuedate] [datetime] NULL,
[psd_applicable_month] [tinyint] NULL,
[psd_applicable_year] [int] NULL,
[SDM_ITEMCODE_Exclude_ind] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SDM_ITEMCODE_Exclude_List] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_psc_id] ON [dbo].[payschedulesdetail] ([psd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payschedulesdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[payschedulesdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payschedulesdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[payschedulesdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[payschedulesdetail] TO [public]
GO
