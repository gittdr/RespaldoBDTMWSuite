CREATE TABLE [dbo].[tblTrucks]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TruckID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TruckName] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispSysTruckID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultDriver] [int] NULL,
[DefaultCabUnit] [int] NULL,
[CurrentDispatcher] [int] NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[Retired] [int] NULL,
[KeepHistory] [bit] NOT NULL,
[MAPIProfile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAPIPassword] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InternetAlias] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupFlag] [int] NULL CONSTRAINT [DF__tblTrucks__Group__43D61337] DEFAULT (0),
[UseAdminMailBox] [int] NOT NULL CONSTRAINT [DF__tblTrucks__UseAd__094F401A] DEFAULT (0),
[SMTPReplyAddress] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblTrucks__SMTPR__0C2BACC5] DEFAULT (''),
[EmailFolderID] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblTrucks__Email__0F081970] DEFAULT (''),
[AfterEmailSend] [int] NOT NULL CONSTRAINT [DF__tblTrucks__After__11E4861B] DEFAULT (0),
[SMTPLogin] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblTrucks__SMTPL__14C0F2C6] DEFAULT (''),
[SMTPPassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblTrucks__SMTPP__179D5F71] DEFAULT (''),
[EMailFolderName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblTrucks__EMail__1A79CC1C] DEFAULT (''),
[AlternateID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblTrucks__Alter__1D5638C7] DEFAULT (''),
[GenericReeferUnitSN] [int] NULL,
[updated_on] [datetime] NULL,
[PositionsBox] [int] NULL,
[MaxDelayMins] [int] NULL,
[DelayedUntil] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTrucks] ADD CONSTRAINT [PK_tblTrucks_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddrTrucksDefCab] ON [dbo].[tblTrucks] ([DefaultCabUnit]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddrTrucksDriver] ON [dbo].[tblTrucks] ([DefaultDriver]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TruckByDelayDate] ON [dbo].[tblTrucks] ([DelayedUntil], [SN], [InBox]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SysDispID] ON [dbo].[tblTrucks] ([DispSysTruckID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tbltrucksdispsystruckid] ON [dbo].[tblTrucks] ([DispSysTruckID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [InBox] ON [dbo].[tblTrucks] ([InBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [InternetAlias] ON [dbo].[tblTrucks] ([InternetAlias]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [OutBox] ON [dbo].[tblTrucks] ([OutBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddrTrucksTruck] ON [dbo].[tblTrucks] ([TruckName]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTrucks] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTrucks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTrucks] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTrucks] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTrucks] TO [public]
GO
