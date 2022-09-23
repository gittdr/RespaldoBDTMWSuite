CREATE TABLE [dbo].[tblRS]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[keyCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[static] [bit] NOT NULL CONSTRAINT [DF_tblRS_static_1__29] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRS] ADD CONSTRAINT [PK_tblRS_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [key_] ON [dbo].[tblRS] ([keyCode]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblRS] TO [public]
GO
GRANT INSERT ON  [dbo].[tblRS] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblRS] TO [public]
GO
GRANT SELECT ON  [dbo].[tblRS] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblRS] TO [public]
GO
