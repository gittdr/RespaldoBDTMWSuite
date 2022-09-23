CREATE TABLE [dbo].[dwTractorAvailabilitySamplingData]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[SamplingID] [int] NULL,
[SamplingDate] [datetime] NULL,
[trc_number] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seated_Driver1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seated_Driver2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Working_Driver1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Working_Driver2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Planned_Driver1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Planned_Driver2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seated] [int] NULL,
[Unseated] [int] NULL,
[WorkingNow] [int] NULL,
[Planned] [int] NULL,
[Assigned] [int] NULL,
[Waiting] [int] NULL,
[OnExpiration] [int] NULL,
[LegOfRecord] [int] NULL,
[RevType1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType4] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dwTimestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dwTractorAvailabilitySamplingData] ADD CONSTRAINT [PK__dwTractorAvailab__0AFD845F] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dwTractorAvailabilitySamplingData] TO [public]
GO
GRANT INSERT ON  [dbo].[dwTractorAvailabilitySamplingData] TO [public]
GO
GRANT SELECT ON  [dbo].[dwTractorAvailabilitySamplingData] TO [public]
GO
GRANT UPDATE ON  [dbo].[dwTractorAvailabilitySamplingData] TO [public]
GO
