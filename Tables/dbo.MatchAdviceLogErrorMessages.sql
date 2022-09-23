CREATE TABLE [dbo].[MatchAdviceLogErrorMessages]
(
[malem_id] [int] NOT NULL IDENTITY(1, 1),
[mal_id] [int] NOT NULL,
[malem_error_message] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[malem_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[malem_updatedate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MatchAdviceLogErrorMessages] ADD CONSTRAINT [PK_MatchAdviceLogErrorMessages] PRIMARY KEY CLUSTERED ([malem_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_MatchAdviceLogErrorMessages_MalID] ON [dbo].[MatchAdviceLogErrorMessages] ([mal_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MatchAdviceLogErrorMessages] TO [public]
GO
GRANT INSERT ON  [dbo].[MatchAdviceLogErrorMessages] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MatchAdviceLogErrorMessages] TO [public]
GO
GRANT SELECT ON  [dbo].[MatchAdviceLogErrorMessages] TO [public]
GO
GRANT UPDATE ON  [dbo].[MatchAdviceLogErrorMessages] TO [public]
GO
