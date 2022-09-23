CREATE TABLE [dbo].[cdfuelbill_columnlist]
(
[cfb_columnname] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_directbill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_columnlist_cfb_directbill] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_columnlist] ADD CONSTRAINT [pk_cdfuelbillcolumnlist] PRIMARY KEY CLUSTERED ([cfb_columnname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdfuelbill_columnlist] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_columnlist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbill_columnlist] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_columnlist] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_columnlist] TO [public]
GO
