CREATE TABLE [dbo].[carrierqualifications]
(
[caq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[caq_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caq_date] [datetime] NULL,
[caq_carrier_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[caq_quantity] [int] NULL,
[caq_expire_date] [datetime] NULL,
[caq_expire_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caq_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caq_value] [decimal] (10, 2) NULL,
[caq_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierqualifications] ADD CONSTRAINT [PK_carrierqualifications] PRIMARY KEY NONCLUSTERED ([caq_type], [caq_carrier_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierqualifications] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierqualifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierqualifications] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierqualifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierqualifications] TO [public]
GO
