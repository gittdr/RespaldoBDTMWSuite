CREATE TABLE [dbo].[inventory_log]
(
[il_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[il_tractor] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[il_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[il_quantity] [int] NOT NULL,
[il_inventory_by] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[il_inventory_date] [datetime] NOT NULL,
[stp_number] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[il_invtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[il_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_il] ON [dbo].[inventory_log] ([il_trailer], [il_tractor], [il_type], [il_inventory_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inventory_log] TO [public]
GO
GRANT INSERT ON  [dbo].[inventory_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[inventory_log] TO [public]
GO
GRANT SELECT ON  [dbo].[inventory_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[inventory_log] TO [public]
GO
