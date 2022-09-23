CREATE TABLE [dbo].[userobject_pb7]
(
[id] [int] NOT NULL,
[dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[original_dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[view_versiondate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userobject_pb7] ADD CONSTRAINT [PK__userobject_pb7__7BDF6B0C] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userobject_pb7] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject_pb7] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userobject_pb7] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject_pb7] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject_pb7] TO [public]
GO
