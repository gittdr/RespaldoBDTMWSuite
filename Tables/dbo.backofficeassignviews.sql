CREATE TABLE [dbo].[backofficeassignviews]
(
[bov_appid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bova_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_validviews] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bova_usertype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__backoffic__bova___0CE961F0] DEFAULT ('USER')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[backofficeassignviews] ADD CONSTRAINT [pk_bovassign] PRIMARY KEY NONCLUSTERED ([bov_id], [bova_userid], [bova_usertype], [bov_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[backofficeassignviews] TO [public]
GO
GRANT INSERT ON  [dbo].[backofficeassignviews] TO [public]
GO
GRANT SELECT ON  [dbo].[backofficeassignviews] TO [public]
GO
GRANT UPDATE ON  [dbo].[backofficeassignviews] TO [public]
GO
