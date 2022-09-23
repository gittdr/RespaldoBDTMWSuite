CREATE TABLE [dbo].[OutOfRouteApproval]
(
[oor_id] [int] NOT NULL IDENTITY(1, 1),
[oor_approved] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[oor_originalMileage] [int] NOT NULL,
[oor_toleranceMiles] [int] NOT NULL,
[oor_toleranceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oor_toleranceID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oor_acceptedMileage] [int] NOT NULL,
[oor_inroutemiles] [int] NULL,
[oor_triproutemiles] [int] NULL,
[oor_requestby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oor_requestdate] [datetime] NULL,
[oor_requestexpdate] [datetime] NULL,
[oor_decisionby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oor_decisiondate] [datetime] NULL,
[oor_remark] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oor_applieddate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutOfRouteApproval] TO [public]
GO
GRANT INSERT ON  [dbo].[OutOfRouteApproval] TO [public]
GO
GRANT SELECT ON  [dbo].[OutOfRouteApproval] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutOfRouteApproval] TO [public]
GO
