CREATE TABLE [dbo].[NoRegCp]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[folio] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[uuid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mensaje] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoRegCp] ADD CONSTRAINT [PK__NoRegCp__6E4DA4BEAFF8F501] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
