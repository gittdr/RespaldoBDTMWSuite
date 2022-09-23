CREATE TABLE [dbo].[TimeSourceSystem]
(
[TimeSourceSystemId] [smallint] NOT NULL IDENTITY(1, 1),
[TimeSourceAbbr] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeSourceSystem] ADD CONSTRAINT [PK_TimeSourceSystem] PRIMARY KEY CLUSTERED ([TimeSourceSystemId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TimeSourceSystem] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeSourceSystem] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeSourceSystem] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeSourceSystem] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeSourceSystem] TO [public]
GO
