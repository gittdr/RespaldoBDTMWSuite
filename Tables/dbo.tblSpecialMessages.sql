CREATE TABLE [dbo].[tblSpecialMessages]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Class] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Enabled] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSpecialMessages] ADD CONSTRAINT [PK_tblSpecialMessages] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblSpecialMessages] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSpecialMessages] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSpecialMessages] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSpecialMessages] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSpecialMessages] TO [public]
GO
