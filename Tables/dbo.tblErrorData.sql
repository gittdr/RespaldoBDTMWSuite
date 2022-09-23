CREATE TABLE [dbo].[tblErrorData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[VBError] [int] NULL,
[Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [datetime] NULL,
[ErrListID] [int] NULL,
[ts] [timestamp] NULL,
[View] [int] NULL,
[Page] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrorData] ADD CONSTRAINT [PK_tblErrorData_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ErrList] ON [dbo].[tblErrorData] ([ErrListID], [Timestamp]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblErrorData] TO [public]
GO
GRANT INSERT ON  [dbo].[tblErrorData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblErrorData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblErrorData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblErrorData] TO [public]
GO
