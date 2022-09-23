CREATE TABLE [dbo].[dw_RTDefinitions]
(
[rt_SN] [int] NOT NULL IDENTITY(1, 1),
[rt_DefName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_HomeDefinitionMode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_HomeValueList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_BeginStopEventsList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_ReturnDefinitionMode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_ReturnValueList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_EndStopEventsList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_MaxTimeFrameInDays] [int] NULL,
[rt_PeekAheadCompletionYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_TrcType1List] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__0FAC5F8C] DEFAULT (''),
[rt_TrcType2List] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__10A083C5] DEFAULT (''),
[rt_TrcType3List] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__1194A7FE] DEFAULT (''),
[rt_TrcType4List] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__1288CC37] DEFAULT (''),
[rt_TrcCompanyList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__137CF070] DEFAULT (''),
[rt_TrcDivisionList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__147114A9] DEFAULT (''),
[rt_TrcTerminalList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__156538E2] DEFAULT (''),
[rt_TrcFleetList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Tr__16595D1B] DEFAULT (''),
[rt_Active] [int] NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Ac__174D8154] DEFAULT ((0)),
[rt_ExcludeTrcList] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__dw_RTDefi__rt_Ex__1841A58D] DEFAULT (''),
[dw_Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dw_RTDefinitions] ADD CONSTRAINT [PK__dw_RTDefinitions__0EB83B53] PRIMARY KEY CLUSTERED ([rt_SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_DW_RTDefinitions_timestamp] ON [dbo].[dw_RTDefinitions] ([dw_Timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dw_RTDefinitions] TO [public]
GO
GRANT INSERT ON  [dbo].[dw_RTDefinitions] TO [public]
GO
GRANT SELECT ON  [dbo].[dw_RTDefinitions] TO [public]
GO
GRANT UPDATE ON  [dbo].[dw_RTDefinitions] TO [public]
GO
