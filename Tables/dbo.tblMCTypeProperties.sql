CREATE TABLE [dbo].[tblMCTypeProperties]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MCSN] [int] NULL,
[PropSN] [int] NOT NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [int] NULL,
[SeqNo] [int] NULL,
[FieldSN] [int] NULL,
[FormSN] [int] NULL,
[PropertyValueIndex] [int] NULL,
[MsgSN] [int] NULL,
[Row] [int] NULL,
[Col] [int] NULL,
[GF_SN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMCTypeProperties] ADD CONSTRAINT [PK_SNPropSN] PRIMARY KEY CLUSTERED ([SN], [PropSN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FieldSN] ON [dbo].[tblMCTypeProperties] ([FieldSN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FormSN] ON [dbo].[tblMCTypeProperties] ([FormSN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MCSN] ON [dbo].[tblMCTypeProperties] ([MCSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMCTypeProperties] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMCTypeProperties] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMCTypeProperties] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMCTypeProperties] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMCTypeProperties] TO [public]
GO
