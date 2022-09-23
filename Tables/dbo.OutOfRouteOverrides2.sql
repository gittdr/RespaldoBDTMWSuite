CREATE TABLE [dbo].[OutOfRouteOverrides2]
(
[mov_number] [int] NOT NULL,
[outofroute_stp_number] [int] NOT NULL,
[outofroute_stp_cmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outofroute_stp_city] [int] NOT NULL,
[overridenby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[outofroute_remark] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OutOfRouteOverrides2] ADD CONSTRAINT [PK_OutOfRouteOverrides2] PRIMARY KEY CLUSTERED ([mov_number], [outofroute_stp_number], [outofroute_stp_city]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutOfRouteOverrides2] TO [public]
GO
GRANT INSERT ON  [dbo].[OutOfRouteOverrides2] TO [public]
GO
GRANT SELECT ON  [dbo].[OutOfRouteOverrides2] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutOfRouteOverrides2] TO [public]
GO
