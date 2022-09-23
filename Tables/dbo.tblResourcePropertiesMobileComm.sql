CREATE TABLE [dbo].[tblResourcePropertiesMobileComm]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCSN] [int] NOT NULL,
[PropSN] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblResourcePropertiesMobileComm] ADD CONSTRAINT [PK_tblResourcePropertiesMobileComm] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblResourcePropertiesMobileComm] TO [public]
GO
GRANT INSERT ON  [dbo].[tblResourcePropertiesMobileComm] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblResourcePropertiesMobileComm] TO [public]
GO
GRANT SELECT ON  [dbo].[tblResourcePropertiesMobileComm] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblResourcePropertiesMobileComm] TO [public]
GO
