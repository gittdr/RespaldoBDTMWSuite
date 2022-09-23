CREATE TABLE [dbo].[edi_210]
(
[data_col] [varchar] (285) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[identity_col] [int] NOT NULL IDENTITY(1, 1),
[trp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_210] ADD CONSTRAINT [PK_edi_210] PRIMARY KEY CLUSTERED ([identity_col]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_210] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_210] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_210] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_210] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_210] TO [public]
GO
