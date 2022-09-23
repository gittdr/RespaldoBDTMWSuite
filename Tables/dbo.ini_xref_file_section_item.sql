CREATE TABLE [dbo].[ini_xref_file_section_item]
(
[file_section_item_id] [int] NOT NULL,
[file_section_id] [int] NOT NULL,
[item_id] [int] NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_xref_file_section_item] ADD CONSTRAINT [ini_xref_file_section_item_pk] PRIMARY KEY CLUSTERED ([file_section_item_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_xref_file_section_item] ADD CONSTRAINT [FK_INI_XREF_REF_19188_INI_XREF] FOREIGN KEY ([file_section_id]) REFERENCES [dbo].[ini_xref_file_section] ([file_section_id])
GO
ALTER TABLE [dbo].[ini_xref_file_section_item] ADD CONSTRAINT [FK_INI_XREF_REF_19189_INI_ITEM] FOREIGN KEY ([item_id]) REFERENCES [dbo].[ini_item] ([item_id])
GO
GRANT DELETE ON  [dbo].[ini_xref_file_section_item] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_xref_file_section_item] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_xref_file_section_item] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_xref_file_section_item] TO [public]
GO
