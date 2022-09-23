CREATE TABLE [dbo].[tblFileVersions]
(
[Machine] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateText] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFileVersions] ADD CONSTRAINT [tblFileVersionsFileCodeNotBlank] CHECK (([FileCode]<>''))
GO
ALTER TABLE [dbo].[tblFileVersions] ADD CONSTRAINT [tblFileVersionsMachineNotBlank] CHECK (([Machine]<>''))
GO
ALTER TABLE [dbo].[tblFileVersions] ADD CONSTRAINT [PK_tblFileVersions] PRIMARY KEY CLUSTERED ([Machine], [FileCode]) ON [PRIMARY]
GO
