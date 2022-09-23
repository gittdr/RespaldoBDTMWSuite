CREATE TABLE [dbo].[tblOttAssignTrailerMonPlanStage]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TrailerID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrailerSCAC] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonitoringPlanId] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecStatCode] [int] NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedOn] [datetime] NOT NULL,
[UpdatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOttAssignTrailerMonPlanStage] ADD CONSTRAINT [PK_tblOttAssignTrailerMonPlanStage] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
