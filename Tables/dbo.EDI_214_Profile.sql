CREATE TABLE [dbo].[EDI_214_Profile]
(
[e214_id] [int] NOT NULL IDENTITY(1, 1),
[e214_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_level] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[e214_ps_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[e214_edi_status] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_status_table_version] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[e214_triggering_activity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_consolidationlevel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_latenoreason_handling] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_sequence] [smallint] NULL,
[e214_stp_position] [int] NULL,
[automail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thirdparty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_ReplicateForEachDropFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_role_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_role_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_role_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderby_role_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_by_edi_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_by_email_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_by_fax_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_wgt_qty] [float] NULL,
[e214_wgt_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_count_qty] [float] NULL,
[e214_count_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_volume_qty] [float] NULL,
[e214_volume_oper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_trlreq_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_latedeparture_handling] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_enforce_sequence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_ref_from_drp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [AK_EDI_214_Profile] ON [dbo].[EDI_214_Profile] ([e214_cmp_id], [e214_level], [e214_triggering_activity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EDI_214_Profile] TO [public]
GO
GRANT INSERT ON  [dbo].[EDI_214_Profile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EDI_214_Profile] TO [public]
GO
GRANT SELECT ON  [dbo].[EDI_214_Profile] TO [public]
GO
GRANT UPDATE ON  [dbo].[EDI_214_Profile] TO [public]
GO
