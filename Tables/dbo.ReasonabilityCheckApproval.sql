CREATE TABLE [dbo].[ReasonabilityCheckApproval]
(
[rcapproval_id] [int] NOT NULL IDENTITY(1, 1),
[rcapproval_paydetailid] [int] NOT NULL,
[rcapproval_lgh_number] [int] NULL,
[rcapproval_pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rcapproval_amount] [money] NOT NULL,
[rcapproval_MinTolerance] [money] NOT NULL,
[rcapproval_MaxTolerance] [money] NOT NULL,
[rcapproval_ForTripTotal] [bit] NOT NULL,
[rcapproval_userid] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rcapproval_approvaldate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReasonabilityCheckApproval_LegNumber] ON [dbo].[ReasonabilityCheckApproval] ([rcapproval_lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReasonabilityCheckApproval_PayDetailId] ON [dbo].[ReasonabilityCheckApproval] ([rcapproval_paydetailid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ReasonabilityCheckApproval] TO [public]
GO
GRANT INSERT ON  [dbo].[ReasonabilityCheckApproval] TO [public]
GO
GRANT SELECT ON  [dbo].[ReasonabilityCheckApproval] TO [public]
GO
GRANT UPDATE ON  [dbo].[ReasonabilityCheckApproval] TO [public]
GO
