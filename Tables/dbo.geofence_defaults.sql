CREATE TABLE [dbo].[geofence_defaults]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[gfc_auto_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_evt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_radius] [decimal] (7, 2) NULL,
[gfc_auto_radiusunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_timeout] [int] NULL,
[gfc_auto_call_occur] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_call_late] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_formid_occur] [int] NULL,
[gfc_auto_formid_late] [int] NULL,
[gfc_auto_email_occur] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_email_late] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_email_occur_cc] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_email_late_cc] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_replyformid_occur] [int] NULL,
[gfc_auto_replyformid_late] [int] NULL,
[gfc_detention_warning_interval] [int] NULL,
[gfc_detention_warning_method] [int] NULL,
[gfc_driver_audible_prompt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_driver_negative_prompt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gfc_auto_form_id_occur_2] [int] NULL,
[gfc_auto_form_id_occur_3] [int] NULL,
[gfc_auto_form_id_rule] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[geofence_defaults] ADD CONSTRAINT [pk_geofence_defaults] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [sk_geofence_cmpevttype] ON [dbo].[geofence_defaults] ([gfc_auto_cmp_id], [gfc_auto_evt], [gfc_auto_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[geofence_defaults] TO [public]
GO
GRANT INSERT ON  [dbo].[geofence_defaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[geofence_defaults] TO [public]
GO
GRANT SELECT ON  [dbo].[geofence_defaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[geofence_defaults] TO [public]
GO
