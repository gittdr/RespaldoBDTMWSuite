CREATE TABLE [dbo].[tblHWMIncomingTMP]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TruckID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[Time] [datetime] NULL,
[CN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isHeader] [bit] NOT NULL,
[Lat] [int] NULL,
[Long] [int] NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHWMIncomingTMP] ADD CONSTRAINT [PK_tblHWMIncomingTMP_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TruckID] ON [dbo].[tblHWMIncomingTMP] ([TruckID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMIncomingTMP].[isHeader]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMIncomingTMP].[Lat]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMIncomingTMP].[Long]'
GO
GRANT DELETE ON  [dbo].[tblHWMIncomingTMP] TO [public]
GO
GRANT INSERT ON  [dbo].[tblHWMIncomingTMP] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblHWMIncomingTMP] TO [public]
GO
GRANT SELECT ON  [dbo].[tblHWMIncomingTMP] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblHWMIncomingTMP] TO [public]
GO
