CREATE TABLE [dbo].[tblPropertiesMobileComm]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCSN] [int] NOT NULL,
[PropSN] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPropertiesMobileComm] ADD CONSTRAINT [PK_tblPropertiesMobileComm_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPropertiesMobileComm] TO [public]
GO
GRANT INSERT ON  [dbo].[tblPropertiesMobileComm] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblPropertiesMobileComm] TO [public]
GO
GRANT SELECT ON  [dbo].[tblPropertiesMobileComm] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblPropertiesMobileComm] TO [public]
GO
