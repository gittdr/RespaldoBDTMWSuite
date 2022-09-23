CREATE TABLE [dbo].[interface_constants]
(
[ifc_tablename] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ifc_columnname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ifc_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[interface_constants] ADD CONSTRAINT [uk_constants] PRIMARY KEY NONCLUSTERED ([ifc_tablename], [ifc_columnname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[interface_constants] TO [public]
GO
GRANT INSERT ON  [dbo].[interface_constants] TO [public]
GO
GRANT REFERENCES ON  [dbo].[interface_constants] TO [public]
GO
GRANT SELECT ON  [dbo].[interface_constants] TO [public]
GO
GRANT UPDATE ON  [dbo].[interface_constants] TO [public]
GO
