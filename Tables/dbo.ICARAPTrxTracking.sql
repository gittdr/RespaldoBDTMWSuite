CREATE TABLE [dbo].[ICARAPTrxTracking]
(
[ICARAPTRCK_id] [int] NOT NULL IDENTITY(1, 1),
[icarap_lgh_number] [int] NULL,
[icarap_ord_hdrnumber] [int] NULL,
[icarap_mov_number] [int] NULL,
[icarap_original_ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icarap_original_ivh_hdrnumber] [int] NULL,
[icarap_new_ivh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icarap_new_ivh_hdrnumber] [int] NULL,
[icarap_asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icarap_asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[icarap_pyd_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ICARAPTrxTracking] ADD CONSTRAINT [ICARAPTRCK_id] PRIMARY KEY CLUSTERED ([ICARAPTRCK_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ICARAPTrxTracking] TO [public]
GO
GRANT INSERT ON  [dbo].[ICARAPTrxTracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ICARAPTrxTracking] TO [public]
GO
GRANT SELECT ON  [dbo].[ICARAPTrxTracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[ICARAPTrxTracking] TO [public]
GO
