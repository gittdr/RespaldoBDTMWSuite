CREATE TABLE [dbo].[tmw_vista_pnfs]
(
[v_Orden_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_orderstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_drvtype3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_total_Rev] [money] NULL,
[v_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_revType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_revType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[v_delivery_date] [datetime] NULL,
[v_difdias] [int] NULL,
[v_diastranssup] [int] NULL,
[v_dd] [int] NULL
) ON [PRIMARY]
GO
