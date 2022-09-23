CREATE TABLE [dbo].[edi_inbound990_records]
(
[trn_id] [int] NOT NULL,
[SCAC] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ISAGSID] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Action] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_dt] [datetime] NULL,
[car_trip_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[processed_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rejection_error_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[warning_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_action_ordnum] ON [dbo].[edi_inbound990_records] ([Action], [ord_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eoo_ord_hdrnumber_990] ON [dbo].[edi_inbound990_records] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ordnum_action] ON [dbo].[edi_inbound990_records] ([ord_number], [Action]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_eoo_trn_id] ON [dbo].[edi_inbound990_records] ([trn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_inbound990_records] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_inbound990_records] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_inbound990_records] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_inbound990_records] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_inbound990_records] TO [public]
GO
