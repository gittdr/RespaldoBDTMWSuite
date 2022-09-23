CREATE TABLE [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores]
(
[log_id] [int] NOT NULL IDENTITY(1, 1),
[query_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[As_Of_Date] [datetime] NULL,
[As_Of_DateSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cargo_Related_Factor] [float] NULL,
[Cargo_Related_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cargo_Related_Rank] [float] NULL,
[Cargo_Related_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrier] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Controlled_Substances_Factor] [float] NULL,
[Controlled_Substances_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Controlled_Substances_Rank] [float] NULL,
[Controlled_Substances_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOT_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_Fitness_Factor] [float] NULL,
[Driver_Fitness_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_Fitness_Rank] [float] NULL,
[Driver_Fitness_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_License_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_License_State] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fatigued_Driving_Factor] [float] NULL,
[Fatigued_Driving_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fatigued_Driving_Rank] [float] NULL,
[Fatigued_Driving_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsafe_Driving_Factor] [float] NULL,
[Unsafe_Driving_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsafe_Driving_Rank] [float] NULL,
[Unsafe_Driving_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Maintenance_Factor] [float] NULL,
[Vehicle_Maintenance_FactorSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Maintenance_Rank] [float] NULL,
[Vehicle_Maintenance_RankSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] ADD CONSTRAINT [PK__CSA_get_Driver_I__2985A09E] PRIMARY KEY NONCLUSTERED ([log_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT INSERT ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT SELECT ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSA_get_Driver_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
