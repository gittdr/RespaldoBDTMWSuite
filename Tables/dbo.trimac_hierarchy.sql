CREATE TABLE [dbo].[trimac_hierarchy]
(
[trimac_terminal] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trimac_company] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trimac_region] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trimac_division] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [trimac_terminal] ON [dbo].[trimac_hierarchy] ([trimac_terminal]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trimac_hierarchy] TO [public]
GO
GRANT INSERT ON  [dbo].[trimac_hierarchy] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trimac_hierarchy] TO [public]
GO
GRANT SELECT ON  [dbo].[trimac_hierarchy] TO [public]
GO
GRANT UPDATE ON  [dbo].[trimac_hierarchy] TO [public]
GO
