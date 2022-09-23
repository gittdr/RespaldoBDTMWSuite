CREATE TABLE [dbo].[nlmshipment]
(
[nlm_shipment_number] [int] NOT NULL,
[accid] [int] NOT NULL,
[acc_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timeout] [datetime] NULL,
[hazmat] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat_un] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat_class] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_shipment] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[critical] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asap] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ready] [datetime] NULL,
[close_time] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[required_vehicle] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terms] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[miles] [int] NULL,
[protect_time] [datetime] NULL,
[tariff_cost] [money] NULL,
[note] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_pieces] [int] NULL,
[shipper_state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_country] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_country] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fastshipment] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ns_first_right_refusal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ns_est_fuel_surcharge] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmshipment_id] ON [dbo].[nlmshipment] ([nlm_shipment_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmshipment] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmshipment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmshipment] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmshipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmshipment] TO [public]
GO
