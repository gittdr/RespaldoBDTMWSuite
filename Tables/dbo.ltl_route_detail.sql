CREATE TABLE [dbo].[ltl_route_detail]
(
[lrd_id] [int] NOT NULL IDENTITY(1, 1),
[lrm_id] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[lrd_sequence] [int] NOT NULL,
[lrd_arrival] [datetime] NOT NULL,
[lrd_departure] [datetime] NOT NULL,
[lrd_earliest] [datetime] NOT NULL,
[lrd_latest] [datetime] NOT NULL,
[lrd_mileage] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_route_detail] ADD CONSTRAINT [lrd_lrm_id] PRIMARY KEY CLUSTERED ([lrd_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_lrd_stp_number] ON [dbo].[ltl_route_detail] ([stp_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_route_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_route_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_route_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_route_detail] TO [public]
GO
