CREATE TABLE [dbo].[tblSelectedMobileComm]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FormSN] [int] NULL,
[MobileCommSN] [int] NULL,
[ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedBySN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSelectedMobileComm] ADD CONSTRAINT [PK_tblSelectedMobileComm_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ID] ON [dbo].[tblSelectedMobileComm] ([ID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedMobileComm].[FormSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedMobileComm].[MobileCommSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedMobileComm].[LastChangedBySN]'
GO
GRANT DELETE ON  [dbo].[tblSelectedMobileComm] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSelectedMobileComm] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSelectedMobileComm] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSelectedMobileComm] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSelectedMobileComm] TO [public]
GO
