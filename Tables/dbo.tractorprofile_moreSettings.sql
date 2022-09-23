CREATE TABLE [dbo].[tractorprofile_moreSettings]
(
[trc_ms_ID] [int] NOT NULL IDENTITY(1, 1),
[resource_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tractorpr__resou__2DB48958] DEFAULT ('TRC'),
[resource_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AutoCloseStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tractorpr__AutoC__2EA8AD91] DEFAULT ('DIS'),
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__tractorpr__lastu__2F9CD1CA] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tractorprofile_moreSettings] ADD CONSTRAINT [PK_TRC_ms_ID] PRIMARY KEY CLUSTERED ([trc_ms_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tractorprofile_moreSettings] ADD CONSTRAINT [fk_trc_ms_ResourceID] FOREIGN KEY ([resource_id]) REFERENCES [dbo].[tractorprofile] ([trc_number])
GO
GRANT DELETE ON  [dbo].[tractorprofile_moreSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[tractorprofile_moreSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tractorprofile_moreSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[tractorprofile_moreSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[tractorprofile_moreSettings] TO [public]
GO
