CREATE TABLE [dbo].[core_carriercommitmentbuckets]
(
[ccb_id] [int] NOT NULL IDENTITY(1, 1),
[carrierlanecommitmentid] [int] NOT NULL,
[ccb_date] [datetime] NOT NULL,
[ccb_assigned] [int] NULL,
[ccb_recommended] [int] NULL,
[ccb_target] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_carriercommitmentbuckets] ADD CONSTRAINT [PK_core_carriercommitmentbuckets] PRIMARY KEY CLUSTERED ([ccb_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ccb_clcid_ccb_date] ON [dbo].[core_carriercommitmentbuckets] ([carrierlanecommitmentid], [ccb_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_carriercommitmentbuckets] TO [public]
GO
GRANT INSERT ON  [dbo].[core_carriercommitmentbuckets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_carriercommitmentbuckets] TO [public]
GO
GRANT SELECT ON  [dbo].[core_carriercommitmentbuckets] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_carriercommitmentbuckets] TO [public]
GO
