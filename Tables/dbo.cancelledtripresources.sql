CREATE TABLE [dbo].[cancelledtripresources]
(
[ord_hdrnumber] [int] NOT NULL,
[lgh_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cancelledtripresources] ADD CONSTRAINT [pk_cancelledtripresources] PRIMARY KEY CLUSTERED ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_cancelledtripresources_timestamp] ON [dbo].[cancelledtripresources] ([dw_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cancelledtripresources] TO [public]
GO
GRANT INSERT ON  [dbo].[cancelledtripresources] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cancelledtripresources] TO [public]
GO
GRANT SELECT ON  [dbo].[cancelledtripresources] TO [public]
GO
GRANT UPDATE ON  [dbo].[cancelledtripresources] TO [public]
GO
