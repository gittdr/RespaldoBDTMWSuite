CREATE TABLE [dbo].[TMSEDI204Companies]
(
[CompanyId] [int] NOT NULL IDENTITY(1, 1),
[StopId] [int] NULL,
[OrderId] [int] NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlternateAddress1] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlternateId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Companies] ADD CONSTRAINT [pk_CompanyId] PRIMARY KEY CLUSTERED ([CompanyId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Companies] ADD CONSTRAINT [FK_TMSEDI204Companies_TMSEDI204Orders] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSEDI204Orders] ([OrderId])
GO
ALTER TABLE [dbo].[TMSEDI204Companies] ADD CONSTRAINT [FK_TMSEDI204Companies_TMSEDI204Stops] FOREIGN KEY ([StopId]) REFERENCES [dbo].[TMSEDI204Stops] ([StopId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Companies] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Companies] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Companies] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Companies] TO [public]
GO
