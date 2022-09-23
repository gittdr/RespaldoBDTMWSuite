CREATE TABLE [dbo].[dvassign]
(
[dv_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dv_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dva_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dv_validviews] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dva_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_dvassign_dva_type] DEFAULT ('USER')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvassign] ADD CONSTRAINT [PK_dvassign] PRIMARY KEY NONCLUSTERED ([dva_userid], [dva_type], [dv_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dvassign] TO [public]
GO
GRANT INSERT ON  [dbo].[dvassign] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dvassign] TO [public]
GO
GRANT SELECT ON  [dbo].[dvassign] TO [public]
GO
GRANT UPDATE ON  [dbo].[dvassign] TO [public]
GO
