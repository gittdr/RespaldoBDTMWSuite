CREATE TABLE [dbo].[Metric_RTLegCache]
(
[rt_SN] [int] NOT NULL IDENTITY(1, 1),
[rt_DefName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_EndLeg] [int] NULL,
[rt_EndDate] [datetime] NULL,
[rt_Seq] [int] NULL,
[rt_Move] [int] NULL,
[rt_Truck] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LegStart] [datetime] NULL,
[rt_Leg] [int] NULL,
[rt_LegEnd] [datetime] NULL,
[rt_LegType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_TimeForLeg] [float] NULL,
[rt_LHRevForLeg] [float] NULL,
[rt_ACCRevForLeg] [float] NULL,
[rt_LoadMiles] [int] NULL,
[rt_DHMiles] [int] NULL,
[rt_GrossPayForLeg] [float] NULL,
[rt_TollForLeg] [float] NULL,
[rt_EstFuelCostForLeg] [float] NULL,
[rt_FirstCom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstCity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstZip3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstReg1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstReg2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstReg3] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstReg4] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPCom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPCity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPZip3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPReg1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPReg2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPReg3] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_FirstDRPReg4] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndCom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndCity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndZip3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndReg1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndReg2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndReg3] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_PUP2ndReg4] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastCom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastCity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastZip3] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastReg1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastReg2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastReg3] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rt_LastReg4] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
