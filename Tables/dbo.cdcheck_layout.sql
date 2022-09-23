CREATE TABLE [dbo].[cdcheck_layout]
(
[cdh_vendor] [int] NOT NULL,
[cdl_columnname] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdl_columnstart] [int] NOT NULL,
[cdl_columnlength] [int] NOT NULL,
[cdl_decimalplaces] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcheck_layout] ADD CONSTRAINT [pk_cdchecklayout] PRIMARY KEY CLUSTERED ([cdh_vendor], [cdl_columnname]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcheck_layout] ADD CONSTRAINT [fk_cdchecklayout_cdcheckcolumnlist] FOREIGN KEY ([cdl_columnname]) REFERENCES [dbo].[cdcheck_columnlist] ([cdcl_columnname])
GO
ALTER TABLE [dbo].[cdcheck_layout] ADD CONSTRAINT [fk_cdchecklayout_cdcheckheader] FOREIGN KEY ([cdh_vendor]) REFERENCES [dbo].[cdcheck_header] ([cdh_vendor])
GO
GRANT DELETE ON  [dbo].[cdcheck_layout] TO [public]
GO
GRANT INSERT ON  [dbo].[cdcheck_layout] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdcheck_layout] TO [public]
GO
GRANT SELECT ON  [dbo].[cdcheck_layout] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdcheck_layout] TO [public]
GO
