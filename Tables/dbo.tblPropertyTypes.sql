CREATE TABLE [dbo].[tblPropertyTypes]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[PropertyName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPropertyTypes] ADD CONSTRAINT [PK_tblPropertyTypes_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Property_Name] ON [dbo].[tblPropertyTypes] ([PropertyName]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPropertyTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[tblPropertyTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblPropertyTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[tblPropertyTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblPropertyTypes] TO [public]
GO
