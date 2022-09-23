CREATE TABLE [dbo].[core_carriercapacitybuckets]
(
[ccpb_id] [int] NOT NULL IDENTITY(1, 1),
[carrierlanecommitmentid] [int] NOT NULL,
[ccpb_date] [datetime] NOT NULL,
[ccpb_capacity] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_carriercapacitybuckets] ADD CONSTRAINT [PK_core_carriercapacitybuckets] PRIMARY KEY CLUSTERED ([ccpb_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_carriercapacitybuckets] TO [public]
GO
GRANT INSERT ON  [dbo].[core_carriercapacitybuckets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_carriercapacitybuckets] TO [public]
GO
GRANT SELECT ON  [dbo].[core_carriercapacitybuckets] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_carriercapacitybuckets] TO [public]
GO
