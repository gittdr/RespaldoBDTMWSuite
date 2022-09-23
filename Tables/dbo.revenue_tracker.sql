CREATE TABLE [dbo].[revenue_tracker]
(
[rvt_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[ivh_hdrnumber] [int] NOT NULL,
[ivh_definition] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_date] [datetime] NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_amount] [money] NOT NULL,
[tar_number] [int] NULL,
[cur_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_isbackout] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivh_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_updatedby] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_updatesource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_appname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_quantity] [float] NULL,
[ivd_number] [int] NULL,
[rvt_rateby] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rvt_billmiles] [decimal] (9, 1) NULL,
[rvt_billemptymiles] [decimal] (9, 1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[revenue_tracker] ADD CONSTRAINT [PK__revenue_tracker__076592C4] PRIMARY KEY CLUSTERED ([rvt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rvtorderinvoice] ON [dbo].[revenue_tracker] ([ord_hdrnumber], [ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rvtdate] ON [dbo].[revenue_tracker] ([rvt_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[revenue_tracker] TO [public]
GO
GRANT INSERT ON  [dbo].[revenue_tracker] TO [public]
GO
GRANT REFERENCES ON  [dbo].[revenue_tracker] TO [public]
GO
GRANT SELECT ON  [dbo].[revenue_tracker] TO [public]
GO
GRANT UPDATE ON  [dbo].[revenue_tracker] TO [public]
GO
