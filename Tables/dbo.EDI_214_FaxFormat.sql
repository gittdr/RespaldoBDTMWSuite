CREATE TABLE [dbo].[EDI_214_FaxFormat]
(
[Format_ID] [int] NULL,
[Format_Name] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active_Flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Subject_text] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject_Available_Flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comment_text] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment_Available_Flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [AUK_EDI_214_FaxFormat_id] ON [dbo].[EDI_214_FaxFormat] ([Format_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EDI_214_FaxFormat] TO [public]
GO
GRANT INSERT ON  [dbo].[EDI_214_FaxFormat] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EDI_214_FaxFormat] TO [public]
GO
GRANT SELECT ON  [dbo].[EDI_214_FaxFormat] TO [public]
GO
GRANT UPDATE ON  [dbo].[EDI_214_FaxFormat] TO [public]
GO
