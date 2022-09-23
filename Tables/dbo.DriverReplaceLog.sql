CREATE TABLE [dbo].[DriverReplaceLog]
(
[drl_id] [int] NOT NULL IDENTITY(1, 1),
[drl_existingID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drl_newID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drl_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_date] [datetime] NULL,
[drl_tripsChanged] [int] NULL,
[drl_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverReplaceLog] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverReplaceLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverReplaceLog] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverReplaceLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverReplaceLog] TO [public]
GO
