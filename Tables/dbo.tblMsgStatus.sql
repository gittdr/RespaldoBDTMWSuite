CREATE TABLE [dbo].[tblMsgStatus]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgStatus] ADD CONSTRAINT [PK_tblMsgStatus_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Code] ON [dbo].[tblMsgStatus] ([Code]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMsgStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMsgStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMsgStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMsgStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMsgStatus] TO [public]
GO
