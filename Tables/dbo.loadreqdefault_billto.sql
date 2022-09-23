CREATE TABLE [dbo].[loadreqdefault_billto]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[loadreqdefault_ident] [int] NOT NULL,
[billto_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadreqdefault_billto] TO [public]
GO
GRANT INSERT ON  [dbo].[loadreqdefault_billto] TO [public]
GO
GRANT SELECT ON  [dbo].[loadreqdefault_billto] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadreqdefault_billto] TO [public]
GO
