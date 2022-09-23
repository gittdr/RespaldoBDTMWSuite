CREATE TABLE [dbo].[fuelpurchauth]
(
[fpa_id] [int] NOT NULL IDENTITY(1, 1),
[fpa_authnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_req_qty] [decimal] (9, 2) NULL,
[fpa_req_date] [datetime] NULL,
[fpa_trailer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_truckstopcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_truckstopname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_truckstopcity] [int] NULL,
[fpa_truckstopcitynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_mov_number] [int] NULL,
[fpa_ord_hdrnumber] [int] NULL,
[fpa_ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_xfacetype] [int] NULL,
[fpa_approved] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_exptype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_expdate] [datetime] NULL,
[fpa_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_post_date] [datetime] NULL,
[fpa_post_transnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_post_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_post_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_comments] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_tripnumber_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_createddate] [datetime] NULL,
[fpa_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fpa_updateddate] [datetime] NULL,
[fpa_req_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelpurchauth] ADD CONSTRAINT [PK_fuelpurchauth_id] PRIMARY KEY CLUSTERED ([fpa_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_fuelpurchauth_authnumber] ON [dbo].[fuelpurchauth] ([fpa_authnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_fuelpurchauth_req_date_driver] ON [dbo].[fuelpurchauth] ([fpa_req_date], [fpa_driver]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_fuelpurchauth_req_date_tractor] ON [dbo].[fuelpurchauth] ([fpa_req_date], [fpa_tractor]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_fuelpurchauth_req_date_trailer] ON [dbo].[fuelpurchauth] ([fpa_req_date], [fpa_trailer]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelpurchauth] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelpurchauth] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelpurchauth] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelpurchauth] TO [public]
GO
