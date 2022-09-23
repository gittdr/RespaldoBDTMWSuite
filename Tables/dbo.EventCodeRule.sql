CREATE TABLE [dbo].[EventCodeRule]
(
[ecr_ID] [int] NOT NULL IDENTITY(1, 1),
[ect_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecr_status_none] [int] NOT NULL,
[ecr_status_bt] [int] NOT NULL,
[ecr_status_mt] [int] NOT NULL,
[ecr_status_unk] [int] NOT NULL,
[ecr_status_ld] [int] NOT NULL,
[ecr_ResultStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ecr_OrderStopType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRule] [int] NULL,
[ecr_ExtraRuleParm1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm5] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm6] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm7] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm8] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecr_ExtraRuleParm9] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EventCodeRule] TO [public]
GO
GRANT INSERT ON  [dbo].[EventCodeRule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EventCodeRule] TO [public]
GO
GRANT SELECT ON  [dbo].[EventCodeRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[EventCodeRule] TO [public]
GO
