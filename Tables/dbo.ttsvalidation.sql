CREATE TABLE [dbo].[ttsvalidation]
(
[per_objectname] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_columnname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_idtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_id] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_validate] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [k_objcolidtypeid] ON [dbo].[ttsvalidation] ([per_objectname], [per_columnname], [per_idtype], [per_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsvalidation] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsvalidation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsvalidation] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsvalidation] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsvalidation] TO [public]
GO
