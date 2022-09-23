CREATE TABLE [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores]
(
[log_id] [int] NOT NULL IDENTITY(1, 1),
[query_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[As_Of_Date] [datetime] NULL,
[As_Of_DateSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BASIC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BASIC_Score_Impact] [float] NULL,
[BASIC_Score_ImpactSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date_of_Birth] [datetime] NULL,
[Date_of_BirthSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOT_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_License_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver_License_State] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linked_Vehicle_License_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linked_Vehicle_License_State] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linked_Vehicle_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linked_VIN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Out_of_Service] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Regulation_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Report_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Section_Code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Severity] [int] NULL,
[SeveritySpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time_Weight] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time_WeightSpecified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_License_Number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_License_State] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vehicle_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VIN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] ADD CONSTRAINT [PK__CSA_get_Detail_f__279D582C] PRIMARY KEY NONCLUSTERED ([log_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT INSERT ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT SELECT ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSA_get_Detail_for_Impact_on_CSMS_BASIC_Scores] TO [public]
GO
