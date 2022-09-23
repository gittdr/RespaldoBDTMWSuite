CREATE TABLE [dbo].[nlmlocations]
(
[nlm_shipment_number] [int] NOT NULL,
[nlm_location_id] [int] NOT NULL,
[location_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[location_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_phone] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_difference] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmlocations_id] ON [dbo].[nlmlocations] ([nlm_shipment_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmlocations] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmlocations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmlocations] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmlocations] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmlocations] TO [public]
GO
