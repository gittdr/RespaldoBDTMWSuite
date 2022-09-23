CREATE TABLE [dbo].[Permit_Axle_Configuration]
(
[PAC_ID] [int] NOT NULL IDENTITY(1, 1),
[P_ID] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAC_AxleNumber] [smallint] NOT NULL,
[PAC_PreviousDistance] [float] NULL,
[PAC_TireCount] [smallint] NULL,
[PAC_TireSize] [smallint] NULL,
[PAC_Pad] [float] NULL,
[PAC_LoadWeight] [int] NULL,
[PAC_MaxWeight] [int] NULL,
[PAC_Width] [float] NULL,
[PAC_OverHang] [float] NULL,
[pac_tirespec] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pac_tirerating] [int] NULL,
[PAC_ScaledWeightType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAC_ScaledWeight] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Axle_Configuration] ADD CONSTRAINT [PK_Permit_Axle_Configuration] PRIMARY KEY CLUSTERED ([PAC_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pac_p_id] ON [dbo].[Permit_Axle_Configuration] ([P_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Axle_Configuration] WITH NOCHECK ADD CONSTRAINT [FK_Permit_Axle_Configuration_Permits] FOREIGN KEY ([P_ID]) REFERENCES [dbo].[Permits] ([P_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Axle_Configuration] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Axle_Configuration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Axle_Configuration] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Axle_Configuration] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Axle_Configuration] TO [public]
GO
