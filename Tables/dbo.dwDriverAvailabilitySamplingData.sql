CREATE TABLE [dbo].[dwDriverAvailabilitySamplingData]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[SamplingID] [int] NULL,
[SamplingDate] [datetime] NULL,
[mpp_id] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seated_Tractor] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Working_Tractor] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Planned_Tractor] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seated] [int] NULL,
[Unseated] [int] NULL,
[WorkingNow] [int] NULL,
[Planned] [int] NULL,
[Assigned] [int] NULL,
[Waiting] [int] NULL,
[OnExpiration] [int] NULL,
[dwTimestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dwDriverAvailabilitySamplingData] ADD CONSTRAINT [PK__dwDriverAvailabi__0CE5CCD1] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dwDriverAvailabilitySamplingData] TO [public]
GO
GRANT INSERT ON  [dbo].[dwDriverAvailabilitySamplingData] TO [public]
GO
GRANT SELECT ON  [dbo].[dwDriverAvailabilitySamplingData] TO [public]
GO
GRANT UPDATE ON  [dbo].[dwDriverAvailabilitySamplingData] TO [public]
GO
