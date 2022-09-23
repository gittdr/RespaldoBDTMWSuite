CREATE TABLE [dbo].[tblLinkedMobileComm]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LinkSN] [int] NULL,
[MobileCommSN] [int] NULL,
[Version] [int] NULL,
[Status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCData] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLinkedMobileComm] ADD CONSTRAINT [PK_tblLinkedMobileComm] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblLinkedMobileComm] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLinkedMobileComm] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLinkedMobileComm] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLinkedMobileComm] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLinkedMobileComm] TO [public]
GO
