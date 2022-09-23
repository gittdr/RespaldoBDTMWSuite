CREATE TABLE [dbo].[routesolutiondetail]
(
[lgh_number] [int] NOT NULL,
[seq] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[highway_seg] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[highway_seq_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[highway_seg_miles] [decimal] (6, 1) NULL,
[via_point] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[direction] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interchange] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[request_id] [int] NULL,
[rd_beginlat] [int] NULL,
[rd_beginlong] [int] NULL,
[rd_endlat] [int] NULL,
[rd_endlong] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routesolutiondetail] ADD CONSTRAINT [pk_routesolutiondetail] UNIQUE NONCLUSTERED ([lgh_number], [request_id], [seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routesolutiondetail] TO [public]
GO
GRANT INSERT ON  [dbo].[routesolutiondetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routesolutiondetail] TO [public]
GO
GRANT SELECT ON  [dbo].[routesolutiondetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[routesolutiondetail] TO [public]
GO
