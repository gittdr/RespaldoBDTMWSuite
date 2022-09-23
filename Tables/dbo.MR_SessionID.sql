CREATE TABLE [dbo].[MR_SessionID]
(
[ses_SPID] [int] NOT NULL,
[ses_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ses_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_SessionID] ADD CONSTRAINT [PK_MR_SessionID] PRIMARY KEY CLUSTERED ([ses_SPID], [ses_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_SessionID] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_SessionID] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_SessionID] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_SessionID] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_SessionID] TO [public]
GO
