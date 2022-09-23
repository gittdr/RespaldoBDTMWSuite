CREATE TABLE [dbo].[transf_RMFilter]
(
[transf_user_id] [int] NOT NULL,
[rmf_rm_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rmf_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rmf_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_dt] [datetime] NOT NULL CONSTRAINT [DF_transf_RMFilter_create_dt] DEFAULT (((1)/(1))/(1900))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_RMFilter] ADD CONSTRAINT [PK_transf_RMFilter] PRIMARY KEY CLUSTERED ([transf_user_id], [rmf_rm_name], [rmf_name], [rmf_value]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_RMFilter] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_RMFilter] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_RMFilter] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_RMFilter] TO [public]
GO
