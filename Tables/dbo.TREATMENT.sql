CREATE TABLE [dbo].[TREATMENT]
(
[trt_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[inj_sequence] [tinyint] NOT NULL,
[trt_Date] [datetime] NULL,
[trt_Facility] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacCity] [int] NULL,
[trt_FacCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_FacPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_CompanyFac] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_TreatedByType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_TreatedByName] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_Description] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_Diagnosis] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_MedicalRestrictions] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trt_NextAppt] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TREATMENT_timestamp] ON [dbo].[TREATMENT] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srpinj] ON [dbo].[TREATMENT] ([srp_ID], [inj_sequence], [trt_Date], [trt_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_trtID] ON [dbo].[TREATMENT] ([trt_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TREATMENT] TO [public]
GO
GRANT INSERT ON  [dbo].[TREATMENT] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TREATMENT] TO [public]
GO
GRANT SELECT ON  [dbo].[TREATMENT] TO [public]
GO
GRANT UPDATE ON  [dbo].[TREATMENT] TO [public]
GO
