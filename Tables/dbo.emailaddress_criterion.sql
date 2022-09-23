CREATE TABLE [dbo].[emailaddress_criterion]
(
[em_id] [int] NOT NULL,
[em_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[em_value] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_emailaddress_criterion] ON [dbo].[emailaddress_criterion] ([em_id], [em_type], [em_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[emailaddress_criterion] TO [public]
GO
GRANT INSERT ON  [dbo].[emailaddress_criterion] TO [public]
GO
GRANT REFERENCES ON  [dbo].[emailaddress_criterion] TO [public]
GO
GRANT SELECT ON  [dbo].[emailaddress_criterion] TO [public]
GO
GRANT UPDATE ON  [dbo].[emailaddress_criterion] TO [public]
GO
