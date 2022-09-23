CREATE TABLE [dbo].[OutOfRouteApprovalStop]
(
[oor_id] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[stp_mfh_sequence] [int] NULL,
[stp_city] [int] NOT NULL,
[ooras_is_oor_stp] [bit] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutOfRouteApprovalStop] TO [public]
GO
GRANT INSERT ON  [dbo].[OutOfRouteApprovalStop] TO [public]
GO
GRANT SELECT ON  [dbo].[OutOfRouteApprovalStop] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutOfRouteApprovalStop] TO [public]
GO
