CREATE TABLE [dbo].[nce_email_log]
(
[nce_email_log_id] [int] NOT NULL IDENTITY(1, 1),
[ncee_email_person_id] [int] NOT NULL,
[orig_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parent_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[sf_sequence_number] [int] NOT NULL,
[ncee_email_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nce_email_log] ADD CONSTRAINT [nce_email_log_pk] PRIMARY KEY CLUSTERED ([nce_email_log_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nce_email_log] TO [public]
GO
GRANT INSERT ON  [dbo].[nce_email_log] TO [public]
GO
GRANT SELECT ON  [dbo].[nce_email_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[nce_email_log] TO [public]
GO
