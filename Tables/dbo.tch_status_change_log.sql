CREATE TABLE [dbo].[tch_status_change_log]
(
[status_change_identity] [int] NOT NULL IDENTITY(1, 1),
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_change_reason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_change_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_change_old] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_change_new] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_change_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[status_change_datetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tch_status_change_log] ADD CONSTRAINT [pk_status_change_id] PRIMARY KEY CLUSTERED ([status_change_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tch_status_change_log] TO [public]
GO
GRANT INSERT ON  [dbo].[tch_status_change_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tch_status_change_log] TO [public]
GO
GRANT SELECT ON  [dbo].[tch_status_change_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[tch_status_change_log] TO [public]
GO
