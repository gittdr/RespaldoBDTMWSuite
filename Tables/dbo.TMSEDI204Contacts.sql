CREATE TABLE [dbo].[TMSEDI204Contacts]
(
[ContactId] [int] NOT NULL IDENTITY(1, 1),
[CompanyId] [int] NOT NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Contacts] ADD CONSTRAINT [PK_TMSEDI204Contacts] PRIMARY KEY CLUSTERED ([ContactId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Contacts] ADD CONSTRAINT [FK_TMSEDI204Contacts_TMSEDI204Companies] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[TMSEDI204Companies] ([CompanyId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Contacts] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Contacts] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Contacts] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Contacts] TO [public]
GO
