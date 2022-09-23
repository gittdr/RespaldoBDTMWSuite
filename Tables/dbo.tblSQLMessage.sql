CREATE TABLE [dbo].[tblSQLMessage]
(
[msg_ID] [int] NOT NULL IDENTITY(1, 1),
[msg_date] [datetime] NOT NULL,
[msg_FormID] [int] NOT NULL,
[msg_To] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_ToType] [int] NOT NULL,
[msg_FilterData] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msg_FilterDataDupWaitSeconds] [int] NULL,
[msg_From] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_FromType] [int] NOT NULL,
[msg_Subject] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSQLMessage] ADD CONSTRAINT [PK_tblSQLMessage] PRIMARY KEY CLUSTERED ([msg_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblSQLMessage] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSQLMessage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSQLMessage] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSQLMessage] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSQLMessage] TO [public]
GO
