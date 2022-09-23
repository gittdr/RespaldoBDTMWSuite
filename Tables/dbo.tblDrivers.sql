CREATE TABLE [dbo].[tblDrivers]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DriverID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentTruck] [int] NULL,
[DispSysDriverID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentDispatcher] [int] NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[Retired] [bit] NOT NULL,
[KeepHistory] [bit] NOT NULL,
[InternetMailToDriver] [bit] NOT NULL,
[InternetMailFromDriver] [bit] NOT NULL,
[MAPIProfile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAPIPassword] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InternetAlias] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseAdminMailBox] [int] NOT NULL CONSTRAINT [DF__tblDriver__UseAd__0A436453] DEFAULT (0),
[SMTPReplyAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblDriver__SMTPR__0D1FD0FE] DEFAULT (''),
[EmailFolderID] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblDriver__Email__0FFC3DA9] DEFAULT (''),
[AfterEmailSend] [int] NOT NULL CONSTRAINT [DF__tblDriver__After__12D8AA54] DEFAULT (0),
[SMTPLogin] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblDriver__SMTPL__15B516FF] DEFAULT (''),
[SMTPPassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblDriver__SMTPP__189183AA] DEFAULT (''),
[EMailFolderName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblDriver__EMail__1B6DF055] DEFAULT (''),
[AlternateID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblDriver__Alter__1E4A5D00] DEFAULT (''),
[DriverPassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultCabUnit] [int] NULL,
[updated_on] [datetime] NULL,
[MaxDelayMins] [int] NULL,
[DelayedUntil] [datetime] NULL,
[PositionsBox] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDrivers] ADD CONSTRAINT [PK_tblDrivers_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DriverByDelayDate] ON [dbo].[tblDrivers] ([DelayedUntil], [SN], [InBox]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DispSysDriverID] ON [dbo].[tblDrivers] ([DispSysDriverID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DriverID] ON [dbo].[tblDrivers] ([DriverID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [InternetAlias] ON [dbo].[tblDrivers] ([InternetAlias]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Name] ON [dbo].[tblDrivers] ([Name]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblDrivers] TO [public]
GO
GRANT INSERT ON  [dbo].[tblDrivers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblDrivers] TO [public]
GO
GRANT SELECT ON  [dbo].[tblDrivers] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblDrivers] TO [public]
GO
