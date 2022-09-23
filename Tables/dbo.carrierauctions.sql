CREATE TABLE [dbo].[carrierauctions]
(
[ca_id] [int] NOT NULL IDENTITY(1, 1),
[ca_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[ca_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_load_originearliest] [datetime] NULL,
[ca_load_originlatest] [datetime] NULL,
[ca_load_destearliest] [datetime] NULL,
[ca_load_destlatest] [datetime] NULL,
[ca_end_date] [datetime] NULL,
[ca_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cgp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_rating_and_higher] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clc_car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clc_rating_and_higher] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laneid] [int] NULL,
[ca_auction_amount] [money] NULL,
[ca_message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_send_via] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_send_sequentially] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_send_sequentially1] [int] NULL,
[ca_send_sequentially2] [int] NULL,
[ca_send_sequentially3] [int] NULL,
[ca_send_sequentially4] [int] NULL,
[ca_send_from_server] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[laneorigintype] [int] NULL,
[lanedesttype] [int] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ca_createdby_lane_auction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierauctions] ADD CONSTRAINT [pk_carrierauctions_ca_id] PRIMARY KEY CLUSTERED ([ca_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lane_auction] ON [dbo].[carrierauctions] ([ca_createdby_lane_auction]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierauctions_ca_type] ON [dbo].[carrierauctions] ([ca_type]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierauctions_lgh_number] ON [dbo].[carrierauctions] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierauctions] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierauctions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierauctions] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierauctions] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierauctions] TO [public]
GO
