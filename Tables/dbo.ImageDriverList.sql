CREATE TABLE [dbo].[ImageDriverList]
(
[idrl_ID] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idrl_transcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageDriverList] ADD CONSTRAINT [PK__ImageDriverList__67AAF607] PRIMARY KEY CLUSTERED ([idrl_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mppid] ON [dbo].[ImageDriverList] ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageDriverList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageDriverList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageDriverList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageDriverList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageDriverList] TO [public]
GO
