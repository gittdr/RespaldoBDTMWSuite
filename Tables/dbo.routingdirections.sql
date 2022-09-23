CREATE TABLE [dbo].[routingdirections]
(
[mt_identity] [int] NOT NULL,
[rd_sequence] [int] NOT NULL,
[rd_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rd_direction] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rd_route] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rd_distance] [decimal] (7, 2) NULL,
[rd_time] [decimal] (6, 2) NULL,
[rd_interchange] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rd_cumdist] [decimal] (7, 2) NULL,
[rd_cumtime] [decimal] (6, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routingdirections] ADD CONSTRAINT [pk_routingdirections] PRIMARY KEY CLUSTERED ([mt_identity], [rd_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routingdirections] TO [public]
GO
GRANT INSERT ON  [dbo].[routingdirections] TO [public]
GO
GRANT SELECT ON  [dbo].[routingdirections] TO [public]
GO
GRANT UPDATE ON  [dbo].[routingdirections] TO [public]
GO
