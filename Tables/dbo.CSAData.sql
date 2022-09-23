CREATE TABLE [dbo].[CSAData]
(
[csa_id] [int] NOT NULL IDENTITY(1, 1),
[Query_ID] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_licensenumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_licensestate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[As_Of_Date] [datetime] NULL,
[Cargo_Related_Factor] [decimal] (18, 0) NULL,
[Cargo_Related_Rank] [decimal] (18, 0) NULL,
[Cargo_Related_Inspection] [int] NULL,
[Cargo_Related_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cargo_Related_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cargo_Related_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Controlled_Substances_Factor] [decimal] (18, 0) NULL,
[Controlled_Substances_Rank] [decimal] (18, 0) NULL,
[Controlled_Substances_Inspection] [int] NULL,
[Controlled_Substances_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Controlled_Substances_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Controlled_Substances_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_Fitness_Factor] [decimal] (18, 0) NULL,
[Driver_Fitness_Rank] [decimal] (18, 0) NULL,
[Driver_Fitnes_Inspection] [int] NULL,
[Driver_Fitnes_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_Fitnes_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_Fitnes_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fatigued_Driving_Factor] [decimal] (18, 0) NULL,
[Fatigued_Driving_Rank] [decimal] (18, 0) NULL,
[Fatigued_Driving_Inspection] [int] NULL,
[Fatigued_Driving_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fatigued_Driving_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fatigued_Driving_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsafe_Driving_Factor] [decimal] (18, 0) NULL,
[Unsafe_Driving_Rank] [decimal] (18, 0) NULL,
[Unsafe_Driving_Inspection] [int] NULL,
[Unsafe_Driving_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsafe_Driving_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unsafe_Driving_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Maintenance_Factor] [decimal] (18, 0) NULL,
[Vehicle_Maintenance_Rank] [decimal] (18, 0) NULL,
[Vehicle_Maintenance_Inspection] [int] NULL,
[Vehicle_Maintenance_Basic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Maintenance_Serious] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Maintenance_Over] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddt] [datetime] NULL,
[last_updatedby] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrier] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSAData] ADD CONSTRAINT [pk_csa_id] PRIMARY KEY CLUSTERED ([csa_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CSAData] TO [public]
GO
GRANT INSERT ON  [dbo].[CSAData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CSAData] TO [public]
GO
GRANT SELECT ON  [dbo].[CSAData] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSAData] TO [public]
GO
