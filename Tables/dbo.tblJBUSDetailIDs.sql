CREATE TABLE [dbo].[tblJBUSDetailIDs]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[did_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[did_Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[did_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[did_MCSN] [int] NOT NULL,
[did_Comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblJBUSDetailIDs] ADD CONSTRAINT [pk_did_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tblJBUSDetailIDs_MCSNTypeCode] ON [dbo].[tblJBUSDetailIDs] ([did_MCSN], [did_Type], [did_Code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblJBUSDetailIDs] TO [public]
GO
GRANT INSERT ON  [dbo].[tblJBUSDetailIDs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblJBUSDetailIDs] TO [public]
GO
GRANT SELECT ON  [dbo].[tblJBUSDetailIDs] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblJBUSDetailIDs] TO [public]
GO
