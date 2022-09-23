CREATE TABLE [dbo].[routesolutionorigin]
(
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[origin_postal_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[request_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routesolutionorigin] ADD CONSTRAINT [pk_routesolutionorigin] UNIQUE NONCLUSTERED ([lgh_number], [request_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routesolutionorigin] TO [public]
GO
GRANT INSERT ON  [dbo].[routesolutionorigin] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routesolutionorigin] TO [public]
GO
GRANT SELECT ON  [dbo].[routesolutionorigin] TO [public]
GO
GRANT UPDATE ON  [dbo].[routesolutionorigin] TO [public]
GO
