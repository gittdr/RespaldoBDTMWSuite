CREATE TABLE [dbo].[tblTranTaskList]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Task] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Data] [nchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NULL,
[Agent] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTranTaskList] ADD CONSTRAINT [PK_tblTranTaskList] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTranTaskList] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTranTaskList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTranTaskList] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTranTaskList] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTranTaskList] TO [public]
GO
