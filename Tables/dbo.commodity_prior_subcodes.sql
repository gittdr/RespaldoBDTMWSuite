CREATE TABLE [dbo].[commodity_prior_subcodes]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cpr_id] [int] NULL,
[scm_identity] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_prior_subcodes] ADD CONSTRAINT [PK__commodity_prior___4DF80B3E] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [alt_cps] ON [dbo].[commodity_prior_subcodes] ([cpr_id], [scm_identity]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_prior_subcodes] ADD CONSTRAINT [FK__commodity__cpr_i__4EEC2F77] FOREIGN KEY ([cpr_id]) REFERENCES [dbo].[commodity_prior_rules] ([ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[commodity_prior_subcodes] ADD CONSTRAINT [FK__commodity__scm_i__4FE053B0] FOREIGN KEY ([scm_identity]) REFERENCES [dbo].[subcommodity] ([scm_identity]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[commodity_prior_subcodes] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_prior_subcodes] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_prior_subcodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_prior_subcodes] TO [public]
GO
