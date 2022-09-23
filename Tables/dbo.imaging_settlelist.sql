CREATE TABLE [dbo].[imaging_settlelist]
(
[img_controlnumber] [int] NULL,
[img_pyhnumber] [int] NULL,
[img_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[img_dateadded] [datetime] NULL,
[img_status] [tinyint] NULL,
[img_dateprocessed] [datetime] NULL,
[img_statusmsg] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[img_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[imaging_settlelist] ADD CONSTRAINT [PK__imaging_settleli__411DCC9A] PRIMARY KEY CLUSTERED ([img_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[imaging_settlelist] TO [public]
GO
GRANT INSERT ON  [dbo].[imaging_settlelist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[imaging_settlelist] TO [public]
GO
GRANT SELECT ON  [dbo].[imaging_settlelist] TO [public]
GO
GRANT UPDATE ON  [dbo].[imaging_settlelist] TO [public]
GO
