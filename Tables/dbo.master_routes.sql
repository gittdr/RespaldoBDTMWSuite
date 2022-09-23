CREATE TABLE [dbo].[master_routes]
(
[mr_id] [int] NOT NULL IDENTITY(1, 1),
[mr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[stp_number] [int] NULL,
[mr_sequence] [int] NULL,
[mr_arrival] [datetime] NULL,
[mr_departure] [datetime] NULL,
[mr_earliest] [datetime] NULL,
[mr_latest] [datetime] NULL,
[mr_leg] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[master_routes] ADD CONSTRAINT [PK__master_routes__7DF95E82] PRIMARY KEY CLUSTERED ([mr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[master_routes] TO [public]
GO
GRANT INSERT ON  [dbo].[master_routes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[master_routes] TO [public]
GO
GRANT SELECT ON  [dbo].[master_routes] TO [public]
GO
GRANT UPDATE ON  [dbo].[master_routes] TO [public]
GO
