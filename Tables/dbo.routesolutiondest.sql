CREATE TABLE [dbo].[routesolutiondest]
(
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[dest_postal_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_miles] [decimal] (7, 1) NULL,
[request_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routesolutiondest] ADD CONSTRAINT [pk_routesolutiondest] UNIQUE NONCLUSTERED ([lgh_number], [request_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routesolutiondest] TO [public]
GO
GRANT INSERT ON  [dbo].[routesolutiondest] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routesolutiondest] TO [public]
GO
GRANT SELECT ON  [dbo].[routesolutiondest] TO [public]
GO
GRANT UPDATE ON  [dbo].[routesolutiondest] TO [public]
GO
