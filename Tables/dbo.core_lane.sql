CREATE TABLE [dbo].[core_lane]
(
[laneid] [int] NOT NULL IDENTITY(1, 1),
[lanecode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lanename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NULL CONSTRAINT [DF_core_Lane_Updated] DEFAULT (getdate()),
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yn_carrierhub] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DK_core_lane_RateMode] DEFAULT ('TRK'),
[UseCarrierConnect] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DK_core_lane_UseCarrierConnect] DEFAULT ('N'),
[LaneSource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lane] ADD CONSTRAINT [pk_core_lane_laneid] PRIMARY KEY CLUSTERED ([laneid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_core_lane_lanecode] ON [dbo].[core_lane] ([lanecode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_lane] TO [public]
GO
GRANT INSERT ON  [dbo].[core_lane] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_lane] TO [public]
GO
GRANT SELECT ON  [dbo].[core_lane] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_lane] TO [public]
GO
