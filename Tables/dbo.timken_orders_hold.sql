CREATE TABLE [dbo].[timken_orders_hold]
(
[bol_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_origin_earliestdate] [datetime] NOT NULL,
[ord_origin_latestdate] [datetime] NOT NULL,
[ord_dest_earliestdate] [datetime] NOT NULL,
[ord_dest_latestdate] [datetime] NOT NULL,
[ord_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_totalpieces] [int] NOT NULL,
[ord_remarks] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_revtype2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_inv_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_notes] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_totalweight] [int] NOT NULL,
[yard_number1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[yard_number2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[yard_number3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NULL,
[ord_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dispatch_date] [datetime] NULL,
[ord_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipper_invalid] [int] NULL,
[consignee_invalid] [int] NULL,
[cmd_code_invalid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[timken_orders_hold] ADD CONSTRAINT [pk_timken_orders_hold] PRIMARY KEY CLUSTERED ([bol_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[timken_orders_hold] TO [public]
GO
GRANT INSERT ON  [dbo].[timken_orders_hold] TO [public]
GO
GRANT REFERENCES ON  [dbo].[timken_orders_hold] TO [public]
GO
GRANT SELECT ON  [dbo].[timken_orders_hold] TO [public]
GO
GRANT UPDATE ON  [dbo].[timken_orders_hold] TO [public]
GO
