CREATE TABLE [dbo].[cdcheck_columnlist]
(
[cdcl_columnname] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdcl_columndescription] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcheck_columnlist] ADD CONSTRAINT [pk_cdcheckcolumnlist] PRIMARY KEY CLUSTERED ([cdcl_columnname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdcheck_columnlist] TO [public]
GO
GRANT INSERT ON  [dbo].[cdcheck_columnlist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdcheck_columnlist] TO [public]
GO
GRANT SELECT ON  [dbo].[cdcheck_columnlist] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdcheck_columnlist] TO [public]
GO
