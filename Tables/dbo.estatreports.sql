CREATE TABLE [dbo].[estatreports]
(
[rpt_id] [int] NOT NULL IDENTITY(1, 1),
[reportname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reportid] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatreports] ADD CONSTRAINT [PK_estatreports] PRIMARY KEY NONCLUSTERED ([reportid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatreports] TO [public]
GO
GRANT INSERT ON  [dbo].[estatreports] TO [public]
GO
GRANT SELECT ON  [dbo].[estatreports] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatreports] TO [public]
GO
