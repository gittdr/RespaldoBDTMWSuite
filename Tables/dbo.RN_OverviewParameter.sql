CREATE TABLE [dbo].[RN_OverviewParameter]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Side] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sort] [int] NOT NULL,
[Heading] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrcHeading] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumberOfValues] [int] NULL,
[Colors] [varchar] (1023) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysBack] [int] NULL,
[DaysRange] [int] NULL,
[Parameters] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [int] NULL,
[Page] [int] NULL,
[labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CannedMode] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RN_OverviewParameter] ADD CONSTRAINT [AutoPK_RN_OverviewParameter_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
