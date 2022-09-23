CREATE TABLE [dbo].[InvServicesImportLog]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[DateImported] [datetime] NOT NULL CONSTRAINT [DF_InvServicesImportLog_DateImported] DEFAULT (getdate()),
[Message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalMessages] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvServicesImportLog] ADD CONSTRAINT [PK_InvServicesImportLog] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvServicesImportLog] TO [public]
GO
GRANT INSERT ON  [dbo].[InvServicesImportLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[InvServicesImportLog] TO [public]
GO
GRANT SELECT ON  [dbo].[InvServicesImportLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvServicesImportLog] TO [public]
GO
