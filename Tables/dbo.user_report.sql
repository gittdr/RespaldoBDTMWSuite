CREATE TABLE [dbo].[user_report]
(
[rpt_id] [int] NOT NULL IDENTITY(1, 1),
[rpt_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_server] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_name] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_custom] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__user_repo__rpt_c__534BF7DE] DEFAULT ('N'),
[rpt_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_public] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__user_repo__rpt_p__55344050] DEFAULT ('Y'),
[rpt_email_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_showontoolbar] [bit] NOT NULL CONSTRAINT [DF__user_repo__rpt_s__56286489] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[user_report] ADD CONSTRAINT [CK__user_repo__rpt_c__5257D3A5] CHECK (([rpt_custom]='N' OR [rpt_custom]='Y'))
GO
ALTER TABLE [dbo].[user_report] ADD CONSTRAINT [CK__user_repo__rpt_p__54401C17] CHECK (([rpt_public]='N' OR [rpt_public]='Y'))
GO
ALTER TABLE [dbo].[user_report] ADD CONSTRAINT [PK__user_rep__FB85567322B232FC] PRIMARY KEY CLUSTERED ([rpt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[user_report] TO [public]
GO
GRANT INSERT ON  [dbo].[user_report] TO [public]
GO
GRANT REFERENCES ON  [dbo].[user_report] TO [public]
GO
GRANT SELECT ON  [dbo].[user_report] TO [public]
GO
GRANT UPDATE ON  [dbo].[user_report] TO [public]
GO
