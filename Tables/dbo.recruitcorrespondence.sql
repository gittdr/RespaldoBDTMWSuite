CREATE TABLE [dbo].[recruitcorrespondence]
(
[rcr_id] [int] NOT NULL IDENTITY(1, 1),
[rec_id] [int] NOT NULL,
[rcr_datesent] [datetime] NOT NULL,
[rcr_docname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rcr_method] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[recruitcorrespondence] ADD CONSTRAINT [PK_recruitcorrespondence] PRIMARY KEY CLUSTERED ([rcr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recruitcorrespondence] TO [public]
GO
GRANT INSERT ON  [dbo].[recruitcorrespondence] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recruitcorrespondence] TO [public]
GO
GRANT SELECT ON  [dbo].[recruitcorrespondence] TO [public]
GO
GRANT UPDATE ON  [dbo].[recruitcorrespondence] TO [public]
GO
