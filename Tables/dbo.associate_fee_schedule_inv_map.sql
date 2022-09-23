CREATE TABLE [dbo].[associate_fee_schedule_inv_map]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fee_schedule_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_date] [datetime] NOT NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_fee_schedule_inv_map] ADD CONSTRAINT [assoc_fee_schedule_inv_map_pk] PRIMARY KEY CLUSTERED ([brn_id], [fee_schedule_itemcode], [cht_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_fee_schedule_inv_map] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_fee_schedule_inv_map] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_fee_schedule_inv_map] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_fee_schedule_inv_map] TO [public]
GO
