CREATE TABLE [dbo].[Permit_Req_Default_Criteria]
(
[PRC_ID] [int] NOT NULL IDENTITY(1, 1),
[PRD_ID] [int] NOT NULL,
[PRC_Sequence] [smallint] NOT NULL,
[PRC_Min_Width] [float] NULL,
[PRC_Min_Height] [float] NULL,
[PRC_Min_Length] [float] NULL,
[PRC_Min_Weight] [float] NULL,
[PRC_Escort_Required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRC_Escort_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRC_Escort_Qty] [smallint] NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prc_comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Req_Default_Criteria] ADD CONSTRAINT [PK_Permit_Req_Default_Criteria] PRIMARY KEY CLUSTERED ([PRC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Req_Default_Criteria] ADD CONSTRAINT [FK_Permit_Req_Default_Criteria_Permit_Requirements_Default] FOREIGN KEY ([PRD_ID]) REFERENCES [dbo].[Permit_Requirements_Default] ([PRD_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Req_Default_Criteria] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Req_Default_Criteria] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Req_Default_Criteria] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Req_Default_Criteria] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Req_Default_Criteria] TO [public]
GO
