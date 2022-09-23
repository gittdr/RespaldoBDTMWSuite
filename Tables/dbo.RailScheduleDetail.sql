CREATE TABLE [dbo].[RailScheduleDetail]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RailScheduleID] [int] NOT NULL,
[OriginDay] [int] NOT NULL,
[OriginTime] [datetime] NOT NULL,
[OriginService] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailScheduleDetail_OriginService] DEFAULT ('Y'),
[DestinationDay] [int] NOT NULL,
[DestinationTime] [datetime] NOT NULL,
[DestinationService] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RailScheduleDetail_DestinationService] DEFAULT ('Y'),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_RailScheduleDetail_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_RailScheduleDetail_ModifiedDate] DEFAULT (getdate()),
[rsd_transitdays] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailScheduleDetail] ADD CONSTRAINT [PK_RailScheduleDetail] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailScheduleDetail] ADD CONSTRAINT [IX_RailScheduleDetail_RaiScheduleID_OriginDay_OriginTime_DestinationDay_DestinationTime] UNIQUE NONCLUSTERED ([RailScheduleID], [OriginDay], [OriginTime], [DestinationDay], [DestinationTime]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailScheduleDetail] ADD CONSTRAINT [FK_RailScheduleDetail_RailSchedule] FOREIGN KEY ([RailScheduleID]) REFERENCES [dbo].[RailSchedule] ([ID])
GO
GRANT DELETE ON  [dbo].[RailScheduleDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[RailScheduleDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailScheduleDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[RailScheduleDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailScheduleDetail] TO [public]
GO
