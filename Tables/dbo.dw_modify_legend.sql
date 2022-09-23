CREATE TABLE [dbo].[dw_modify_legend]
(
[dwml_ident] [int] NOT NULL IDENTITY(1, 1),
[dwml_object] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dwml_columnid] [int] NOT NULL,
[dwml_color] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dwml_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dw_modify_legend] TO [public]
GO
GRANT INSERT ON  [dbo].[dw_modify_legend] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dw_modify_legend] TO [public]
GO
GRANT SELECT ON  [dbo].[dw_modify_legend] TO [public]
GO
GRANT UPDATE ON  [dbo].[dw_modify_legend] TO [public]
GO
