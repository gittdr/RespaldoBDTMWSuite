CREATE TABLE [dbo].[directroutelog]
(
[drl_id] [int] NOT NULL IDENTITY(1, 1),
[drh_id] [int] NOT NULL,
[drl_userID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_activity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_date] [datetime] NULL,
[drl_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[directroutelog] ADD CONSTRAINT [PK__directroutelog__1672CC2A] PRIMARY KEY CLUSTERED ([drl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[directroutelog] TO [public]
GO
GRANT INSERT ON  [dbo].[directroutelog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[directroutelog] TO [public]
GO
GRANT SELECT ON  [dbo].[directroutelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[directroutelog] TO [public]
GO
