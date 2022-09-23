CREATE TABLE [dbo].[can_region]
(
[reg_scheme] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reg_regionname] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reg_regionid] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reg_state] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_region] ADD CONSTRAINT [pk_can_region] PRIMARY KEY NONCLUSTERED ([reg_regionid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_region] TO [public]
GO
GRANT INSERT ON  [dbo].[can_region] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_region] TO [public]
GO
GRANT SELECT ON  [dbo].[can_region] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_region] TO [public]
GO
