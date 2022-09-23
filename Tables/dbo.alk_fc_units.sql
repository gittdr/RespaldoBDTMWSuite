CREATE TABLE [dbo].[alk_fc_units]
(
[un_unit] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_tripid] [int] NULL,
[un_driver] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_driver2] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trailer] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_sts] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_teamldr] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_fleet] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_dridiv] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_dridom] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_driterm] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_drityp1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_drityp2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_drityp3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_drityp4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_move] [int] NULL,
[un_vtyp] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_vtyp2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_vtyp3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_vtyp4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trterm] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trfleet] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trcompany] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trdiv] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_gps_date] [datetime] NULL,
[un_gps_lat] [int] NULL,
[un_gps_long] [int] NULL,
[un_contact] [char] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trlrtyp] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trlrtyp2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trlrtyp3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_trlrtyp4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_carrier] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_orig_city] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_orig_st] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_dest_city] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[un_dest_st] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_trip] ON [dbo].[alk_fc_units] ([un_tripid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_unit] ON [dbo].[alk_fc_units] ([un_unit]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[alk_fc_units] TO [public]
GO
GRANT INSERT ON  [dbo].[alk_fc_units] TO [public]
GO
GRANT REFERENCES ON  [dbo].[alk_fc_units] TO [public]
GO
GRANT SELECT ON  [dbo].[alk_fc_units] TO [public]
GO
GRANT UPDATE ON  [dbo].[alk_fc_units] TO [public]
GO
