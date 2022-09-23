CREATE TABLE [dbo].[creditmemo_reason]
(
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmr_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NULL,
[cmr_original_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmr_applyto_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmr_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmr_datecreated] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [inx_cmreason] ON [dbo].[creditmemo_reason] ([ivh_invoicenumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[creditmemo_reason] TO [public]
GO
GRANT INSERT ON  [dbo].[creditmemo_reason] TO [public]
GO
GRANT REFERENCES ON  [dbo].[creditmemo_reason] TO [public]
GO
GRANT SELECT ON  [dbo].[creditmemo_reason] TO [public]
GO
GRANT UPDATE ON  [dbo].[creditmemo_reason] TO [public]
GO
