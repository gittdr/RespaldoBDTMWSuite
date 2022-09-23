CREATE TABLE [dbo].[edi_nonbillable_tender_stops]
(
[nts_id] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[nts_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nts_arv_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nts_arv_date] [datetime] NULL,
[nts_dep_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nts_dep_date] [datetime] NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_nonbillable_tender_stops] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_nonbillable_tender_stops] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_nonbillable_tender_stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_nonbillable_tender_stops] TO [public]
GO
