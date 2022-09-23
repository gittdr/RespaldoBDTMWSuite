CREATE TABLE [dbo].[RatingMessages]
(
[rtm_ident] [int] NOT NULL IDENTITY(1, 1),
[fgdl_ident] [int] NOT NULL,
[rtm_Message] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtm_messagetype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtm_success] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtm_datetime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingMessages] ADD CONSTRAINT [PK_RatingMessages] PRIMARY KEY CLUSTERED ([rtm_ident]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingMessages] ADD CONSTRAINT [FK_RatingMessages_FullGenDetailLog] FOREIGN KEY ([fgdl_ident]) REFERENCES [dbo].[FullGenDetailLog] ([fgdl_ident])
GO
GRANT DELETE ON  [dbo].[RatingMessages] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingMessages] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingMessages] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingMessages] TO [public]
GO
