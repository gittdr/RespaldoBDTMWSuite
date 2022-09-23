CREATE TABLE [dbo].[Partorder_locking]
(
[pol_id] [int] NOT NULL IDENTITY(1, 1),
[poh_identity] [int] NOT NULL,
[pol_lockdatetime] [datetime] NULL,
[pol_lockedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_Partorder_locking] ON [dbo].[Partorder_locking] ([poh_identity], [pol_lockedby], [pol_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Partorder_locking] TO [public]
GO
GRANT INSERT ON  [dbo].[Partorder_locking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Partorder_locking] TO [public]
GO
GRANT SELECT ON  [dbo].[Partorder_locking] TO [public]
GO
GRANT UPDATE ON  [dbo].[Partorder_locking] TO [public]
GO
