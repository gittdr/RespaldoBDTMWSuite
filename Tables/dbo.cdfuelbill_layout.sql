CREATE TABLE [dbo].[cdfuelbill_layout]
(
[cfb_xfacetype] [int] NOT NULL,
[cfb_columnname] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_columnstart] [int] NULL,
[cfb_columnend] [int] NULL,
[cfb_decimalplaces] [int] NULL,
[cfb_directbill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_reconcilefield] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_layout] ADD CONSTRAINT [pk_cdfuelbilllayout] PRIMARY KEY CLUSTERED ([cfb_xfacetype], [cfb_columnname]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_layout] ADD CONSTRAINT [fk_cdfuelbilllayouttoheader] FOREIGN KEY ([cfb_xfacetype]) REFERENCES [dbo].[cdfuelbill_header] ([cfb_xfacetype])
GO
GRANT DELETE ON  [dbo].[cdfuelbill_layout] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_layout] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbill_layout] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_layout] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_layout] TO [public]
GO
