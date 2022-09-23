CREATE TABLE [dbo].[customerbillingrequirements]
(
[cbr_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cbr_req] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cbr_sequence] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerbillingrequirements] ADD CONSTRAINT [prkey_customerbillingrequirements] PRIMARY KEY CLUSTERED ([cbr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_customerbillingrequirements] ON [dbo].[customerbillingrequirements] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[customerbillingrequirements] TO [public]
GO
GRANT INSERT ON  [dbo].[customerbillingrequirements] TO [public]
GO
GRANT SELECT ON  [dbo].[customerbillingrequirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[customerbillingrequirements] TO [public]
GO
