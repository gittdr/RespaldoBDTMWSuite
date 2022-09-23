CREATE TABLE [dbo].[carrierfileaudit]
(
[caf_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[caf_action] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_update_dt] [datetime] NULL,
[caf_update_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_update_field] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_original_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_new_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierfileaudit] ADD CONSTRAINT [pk_carrierfileaudit_caf_id] PRIMARY KEY CLUSTERED ([caf_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierfileaudit_car_id] ON [dbo].[carrierfileaudit] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierfileaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierfileaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierfileaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierfileaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierfileaudit] TO [public]
GO
