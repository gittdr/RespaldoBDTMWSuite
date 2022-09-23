CREATE TABLE [dbo].[taxrate]
(
[tax_type] [smallint] NOT NULL,
[tax_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_rate] [real] NULL,
[tax_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_effectivedate] [datetime] NULL,
[tax_expirationdate] [datetime] NULL,
[tax_id] [int] NOT NULL IDENTITY(1, 1),
[tax_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_appliesto] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax_ARTaxAuth] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[taxrate] ADD CONSTRAINT [PK__taxrate__6B65136E] PRIMARY KEY CLUSTERED ([tax_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[taxrate] TO [public]
GO
GRANT INSERT ON  [dbo].[taxrate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[taxrate] TO [public]
GO
GRANT SELECT ON  [dbo].[taxrate] TO [public]
GO
GRANT UPDATE ON  [dbo].[taxrate] TO [public]
GO
