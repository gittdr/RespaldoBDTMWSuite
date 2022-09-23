CREATE TABLE [dbo].[dx_Xref]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_trpid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_entitytype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_entityname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_xrefkey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_comments] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Xref] ADD CONSTRAINT [PK_dx_Xref] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_Xref] ON [dbo].[dx_Xref] ([dx_importid], [dx_trpid], [dx_entitytype], [dx_entityname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Xref] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Xref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Xref] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Xref] TO [public]
GO
