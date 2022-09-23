CREATE TABLE [dbo].[transcore_zones]
(
[tcz_identity] [int] NOT NULL,
[tcz_zone] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcz_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tcz_statename] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transcore_zones] ADD CONSTRAINT [PK_transcore_zones] PRIMARY KEY NONCLUSTERED ([tcz_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transcore_zones] TO [public]
GO
GRANT INSERT ON  [dbo].[transcore_zones] TO [public]
GO
GRANT SELECT ON  [dbo].[transcore_zones] TO [public]
GO
GRANT UPDATE ON  [dbo].[transcore_zones] TO [public]
GO
