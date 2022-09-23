CREATE TABLE [dbo].[fuelimport_ftpinfo]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cfb_xfacetype] [int] NULL,
[FTPType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HostUri] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Port] [int] NULL,
[RemoteFolder] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocalFolder] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveFolder] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileMask] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL,
[AutoDelete] [bit] NOT NULL CONSTRAINT [DF__fuelimpor__AutoD__10DFDD2B] DEFAULT ((0)),
[UsePassive] [bit] NOT NULL CONSTRAINT [DF__fuelimpor__UsePa__11D40164] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelimport_ftpinfo] ADD CONSTRAINT [PK__fuelimpo__3214EC27A7C9C737] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelimport_ftpinfo] ADD CONSTRAINT [FK__fuelimpor__cfb_x__0FEBB8F2] FOREIGN KEY ([cfb_xfacetype]) REFERENCES [dbo].[cdfuelbill_header] ([cfb_xfacetype])
GO
GRANT DELETE ON  [dbo].[fuelimport_ftpinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelimport_ftpinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelimport_ftpinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelimport_ftpinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelimport_ftpinfo] TO [public]
GO
