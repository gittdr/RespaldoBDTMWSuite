CREATE TABLE [dbo].[dw_RTLegCache]
(
[rt_SN] [int] NOT NULL IDENTITY(1, 1),
[rt_DefName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_StartLeg] [int] NULL,
[rt_StartDate] [datetime] NULL,
[rt_EndDate] [datetime] NULL,
[rt_Seq] [int] NULL,
[rt_Move] [int] NULL,
[rt_Truck] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LegStart] [datetime] NULL,
[rt_Leg] [int] NULL,
[rt_LegEnd] [datetime] NULL,
[rt_LegType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_DateUpdated] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dw_RTLegCache] ADD CONSTRAINT [PK__dw_RTLegCache__1A29EDFF] PRIMARY KEY CLUSTERED ([rt_SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_DW_RTLegCache_timestamp] ON [dbo].[dw_RTLegCache] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RTDef_Leg] ON [dbo].[dw_RTLegCache] ([rt_DefName], [rt_Leg]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Leg_RTDef] ON [dbo].[dw_RTLegCache] ([rt_Leg], [rt_DefName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dw_RTLegCache] TO [public]
GO
GRANT INSERT ON  [dbo].[dw_RTLegCache] TO [public]
GO
GRANT SELECT ON  [dbo].[dw_RTLegCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[dw_RTLegCache] TO [public]
GO
