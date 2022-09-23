CREATE TABLE [dbo].[tblSQLMessageData]
(
[msd_ID] [int] NOT NULL IDENTITY(1, 1),
[msg_ID] [int] NOT NULL,
[msd_Seq] [int] NOT NULL,
[msd_FieldName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msd_FieldValue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSQLMessageData] ADD CONSTRAINT [PK_tblSQLMessageData] PRIMARY KEY CLUSTERED ([msg_ID], [msd_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblSQLMessageData] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSQLMessageData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSQLMessageData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSQLMessageData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSQLMessageData] TO [public]
GO
