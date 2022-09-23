CREATE TABLE [dbo].[im_reservation]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reservation_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cutoff_date] [datetime] NULL,
[container_len] [float] NULL,
[lgh_number] [float] NULL,
[advance_carrier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_carrier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[train_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eta_date] [datetime] NULL,
[lastupdatedon] [datetime] NULL,
[remarks] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[im_reservation] ADD CONSTRAINT [PK__im_reser__3213E83F324AD50E] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [im_reservation_leg] ON [dbo].[im_reservation] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[im_reservation] TO [public]
GO
GRANT INSERT ON  [dbo].[im_reservation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[im_reservation] TO [public]
GO
GRANT SELECT ON  [dbo].[im_reservation] TO [public]
GO
GRANT UPDATE ON  [dbo].[im_reservation] TO [public]
GO
