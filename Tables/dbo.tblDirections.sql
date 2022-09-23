CREATE TABLE [dbo].[tblDirections]
(
[Direction] [smallint] NOT NULL,
[Code] [smallint] NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDirections] ADD CONSTRAINT [PK_tblDirections_Direction] PRIMARY KEY CLUSTERED ([Direction]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Code] ON [dbo].[tblDirections] ([Code]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblDirections] TO [public]
GO
GRANT INSERT ON  [dbo].[tblDirections] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblDirections] TO [public]
GO
GRANT SELECT ON  [dbo].[tblDirections] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblDirections] TO [public]
GO
