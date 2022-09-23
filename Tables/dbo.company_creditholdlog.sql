CREATE TABLE [dbo].[company_creditholdlog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDate] [datetime] NOT NULL,
[UserID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_CreditHoldStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_CreditHoldComment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditHoldOverrideType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreditHoldOverrideReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_creditholdlog] ADD CONSTRAINT [PK__company_creditho__52A48466] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_company_creditholdlog_cmp_id_LogDate] ON [dbo].[company_creditholdlog] ([cmp_id], [LogDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_creditholdlog] TO [public]
GO
GRANT INSERT ON  [dbo].[company_creditholdlog] TO [public]
GO
GRANT SELECT ON  [dbo].[company_creditholdlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_creditholdlog] TO [public]
GO
