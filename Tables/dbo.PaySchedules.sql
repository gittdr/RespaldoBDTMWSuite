CREATE TABLE [dbo].[PaySchedules]
(
[PayScheduleId] [int] NOT NULL IDENTITY(1, 1),
[AccountingType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssetType] [int] NOT NULL CONSTRAINT [DF_AssetType] DEFAULT ((0)),
[GlobalSW] [bit] NOT NULL CONSTRAINT [DF__PaySchedu__Globa__35236ABE] DEFAULT ((0)),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__Creat__36178EF7] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Creat__370BB330] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__LastU__37FFD769] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__LastU__38F3FBA2] DEFAULT (getdate()),
[UseDateType] [int] NOT NULL CONSTRAINT [UseDateType] DEFAULT ((1)),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mode] [int] NULL CONSTRAINT [DF__PaySchedul__Mode__32793E75] DEFAULT ((0)),
[CutOffTimeTicks] [bigint] NULL CONSTRAINT [DF_PayScheduleCutOffTimeTicks] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaySchedules] ADD CONSTRAINT [PK__PaySchedules__342F4685] PRIMARY KEY CLUSTERED ([PayScheduleId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PaySchedules] TO [public]
GO
GRANT INSERT ON  [dbo].[PaySchedules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PaySchedules] TO [public]
GO
GRANT SELECT ON  [dbo].[PaySchedules] TO [public]
GO
GRANT UPDATE ON  [dbo].[PaySchedules] TO [public]
GO
