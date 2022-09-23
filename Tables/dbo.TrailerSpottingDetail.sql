CREATE TABLE [dbo].[TrailerSpottingDetail]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[stp_number] [int] NULL,
[tsd_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tsd_begin_date] [datetime] NULL,
[tsd_end_date] [datetime] NULL,
[tsd_stillspotted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_days] [int] NULL,
[tsd_mileage_charge] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_mileage] [int] NULL,
[tsd_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_authorization_cmp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_authorization_person] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_authorization_phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_authorization_missing] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cancel_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cancel_date] [datetime] NULL,
[tsd_remark] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tsd_manualadd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrailerSpottingDetail] ADD CONSTRAINT [pk_trailerspottingdetail_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tsd_ord_hdrnumber] ON [dbo].[TrailerSpottingDetail] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrailerSpottingDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerSpottingDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrailerSpottingDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerSpottingDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerSpottingDetail] TO [public]
GO
