CREATE TABLE [dbo].[FullGenDetailLog]
(
[fgdl_ident] [int] NOT NULL IDENTITY(1, 1),
[fgl_ident] [int] NOT NULL,
[fgdl_Key_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgdl_rated_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgdl_Key_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fgdl_Key_type] DEFAULT ('PAY')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FullGenDetailLog] ADD CONSTRAINT [PK_FullGenDetailLog] PRIMARY KEY CLUSTERED ([fgdl_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fgdl_key_type_fgdl_key_number] ON [dbo].[FullGenDetailLog] ([fgdl_Key_type], [fgdl_Key_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FullGenDetailLog] ADD CONSTRAINT [FK_FullGenDetailLog_FullGenLog] FOREIGN KEY ([fgl_ident]) REFERENCES [dbo].[FullGenLog] ([fgl_ident])
GO
GRANT DELETE ON  [dbo].[FullGenDetailLog] TO [public]
GO
GRANT INSERT ON  [dbo].[FullGenDetailLog] TO [public]
GO
GRANT SELECT ON  [dbo].[FullGenDetailLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[FullGenDetailLog] TO [public]
GO
