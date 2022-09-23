CREATE TABLE [dbo].[cdfuelbill_mappings_tbl]
(
[cfb_xfacetype] [int] NOT NULL,
[cfb_code] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_mappingdescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_columnname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_skippay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_mappings_tbl] ADD CONSTRAINT [pk_cdfuelbillmappings] PRIMARY KEY CLUSTERED ([cfb_xfacetype], [cfb_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_mappings_tbl] ADD CONSTRAINT [fk_cdfuelbillmappingstoheader] FOREIGN KEY ([cfb_xfacetype]) REFERENCES [dbo].[cdfuelbill_header] ([cfb_xfacetype])
GO
GRANT DELETE ON  [dbo].[cdfuelbill_mappings_tbl] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_mappings_tbl] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_mappings_tbl] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_mappings_tbl] TO [public]
GO
