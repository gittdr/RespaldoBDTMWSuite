CREATE TABLE [dbo].[dx_QueueLocations]
(
[QueueLocationIdent] [int] NOT NULL IDENTITY(1, 1),
[loc_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[loc_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loc_Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loc_Type] [int] NOT NULL CONSTRAINT [DF__dx_QueueL__loc_T__52AF6900] DEFAULT ((0)),
[loc_Host] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loc_Path] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[loc_UserName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loc_Password] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueLocations] ADD CONSTRAINT [PK_dx_QueueLocations] PRIMARY KEY CLUSTERED ([loc_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_QueueLocations] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_QueueLocations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_QueueLocations] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_QueueLocations] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_QueueLocations] TO [public]
GO
EXEC sp_addextendedproperty N'MS_Description', N'More fully descriptive value for this Location.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The host for this Location. This could be a Mapped drive or an FTP Server name.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Host'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique ID for this Location.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Descriptive name for this Locatioon', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The password to valdate the user on this location.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Password'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The path of the Location this is the full path for local drives and truncated paths for remote mahines and servers.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Path'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The type for this Location. 0 = FTP; 1 = Local or LAN', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The user name used to log on to this location.', 'SCHEMA', N'dbo', 'TABLE', N'dx_QueueLocations', 'COLUMN', N'loc_UserName'
GO
