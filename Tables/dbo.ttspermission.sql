CREATE TABLE [dbo].[ttspermission]
(
[per_objectname] [varchar] (81) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_columnname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_idtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_id] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[per_accesslevel] [int] NULL,
[per_validate] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per_errmessage] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per_accesslevel_rule] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ttspermission] ADD CONSTRAINT [AutoPK_ttspermission] PRIMARY KEY CLUSTERED ([per_objectname], [per_columnname], [per_idtype], [per_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttspermission] TO [public]
GO
GRANT INSERT ON  [dbo].[ttspermission] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttspermission] TO [public]
GO
GRANT SELECT ON  [dbo].[ttspermission] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttspermission] TO [public]
GO
