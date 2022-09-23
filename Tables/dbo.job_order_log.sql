CREATE TABLE [dbo].[job_order_log]
(
[jol_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[order_count] [int] NOT NULL,
[driver_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update_by] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[job_order_log] ADD CONSTRAINT [pk_jol_id] PRIMARY KEY CLUSTERED ([jol_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[job_order_log] ADD CONSTRAINT [uk_id_and_ordHdrNumber] UNIQUE NONCLUSTERED ([jol_id], [ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[job_order_log] TO [public]
GO
GRANT INSERT ON  [dbo].[job_order_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[job_order_log] TO [public]
GO
GRANT SELECT ON  [dbo].[job_order_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[job_order_log] TO [public]
GO
