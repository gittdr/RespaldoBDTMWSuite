CREATE TABLE [dbo].[RailBillingHistory]
(
[rbh_id] [int] NOT NULL IDENTITY(1, 1),
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NOT NULL,
[rbh_masterbillid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rbh_origin_ramp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[origin_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origin_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_origin_ramp_actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_dest_ramp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dest_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_dest_ramp_actual] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_location] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billto_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_loaded] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_length] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_weight] [int] NULL,
[rbh_seal_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_benowner] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_quote] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_plan] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_service] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_stcc] [varchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_tenderdate] [datetime] NULL,
[rth_id] [int] NULL,
[rbh_fgt_hazmat_class_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_fgt_hazmat_shipping_name_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_contract_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_notifyparty] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_notifyfax] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_notifyphone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_mintemp] [smallint] NULL,
[rbh_maxtemp] [smallint] NULL,
[rbh_tempunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_weightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_count] [decimal] (10, 2) NULL,
[rbh_countunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_rail_load_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_trailer3] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_trailer4] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_shipping_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_technical_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_cmd_imdg_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_cmd_imdg_packaginggroup] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_BOL_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_Booking_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_cmd_haz_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_tendered_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailBillingHistory_rbh_tendered_by] DEFAULT ('UNKNOWN'),
[rbh_international] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rbh_railschedule_id] [int] NULL,
[rbh_lastupdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailBillingHistory] ADD CONSTRAINT [pk_railbillinghistory_rbh_id] PRIMARY KEY CLUSTERED ([rbh_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_railbillinghistory_lgh_number] ON [dbo].[RailBillingHistory] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RailBillingHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[RailBillingHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailBillingHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[RailBillingHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailBillingHistory] TO [public]
GO
