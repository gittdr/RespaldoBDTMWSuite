CREATE TABLE [dbo].[reportdetail_template]
(
[rtd_id] [int] NOT NULL,
[rtd_fieldname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_fieldlabel] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_restriction] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_restriction_var] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_dbtype] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_attribute_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_attribute] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rtd_primary] ON [dbo].[reportdetail_template] ([rtd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reportdetail_template] TO [public]
GO
GRANT INSERT ON  [dbo].[reportdetail_template] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reportdetail_template] TO [public]
GO
GRANT SELECT ON  [dbo].[reportdetail_template] TO [public]
GO
GRANT UPDATE ON  [dbo].[reportdetail_template] TO [public]
GO
