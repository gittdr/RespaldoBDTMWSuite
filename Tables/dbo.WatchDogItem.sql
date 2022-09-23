CREATE TABLE [dbo].[WatchDogItem]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[WatchName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BeginDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[SqlStatement] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operator] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThresholdValue] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BeginDateMinusDays] [int] NULL,
[EndDatePlusDays] [int] NULL,
[DateField] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QueryType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericOrText] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinsBackToRun] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HTMLTemplateFlag] [bit] NULL CONSTRAINT [DF_WatchDogItem_HTMLTemplateFlag] DEFAULT ((1)),
[ActiveFlag] [bit] NULL CONSTRAINT [DF_WatchDogItem_ActiveFlag] DEFAULT ((1)),
[DefaultCurrency] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyDateType] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastRunDate] [datetime] NULL,
[ScheduleWatchDog] [bit] NULL CONSTRAINT [DF__WatchDogI__Sched__0FDB44F7] DEFAULT ((0)),
[TimeValue] [int] NULL,
[TimeType] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunMinsBackFromScheduleTime] [bit] NULL,
[AttachFileToEmail] [bit] NULL,
[AttachType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentWatchName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubjectNamingRule] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentFileNamingRule] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateFlag] [bit] NULL,
[WorkflowDataSourceSN] [int] NULL,
[Workflow_Template_ID] [int] NULL,
[WorkFlow_Current_Sequence_ID] [int] NULL,
[ConsecutiveFailures] [int] NULL CONSTRAINT [DF__WatchDogI__Conse__2493A0F3] DEFAULT ((0)),
[ConsecutiveFailuresLimit] [int] NULL CONSTRAINT [DF__WatchDogI__Conse__2587C52C] DEFAULT ((3)),
[DataSourceSN] [int] NULL,
[TotalMailDynamicSend_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailDataSourceSN] [int] NULL,
[TotalMailDynamicSend_AddressTypeForRecipient] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailDynamicSend_FieldToUse] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailDynamicSend_ReferenceLookup] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormatTotalMailGroupAndLogonMsgsAsTabular_YN] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TemplateFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__WatchDogI__Templ__3005539F] DEFAULT ('Multiple2.htm'),
[SubjectOverride] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentFilenameOverride] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailFormId] [int] NULL,
[WatchdogTimeOut] [int] NULL CONSTRAINT [DF__WatchDogI__Watch__34CA08BC] DEFAULT ((30)),
[CheckedOut] [int] NULL,
[ScheduledRun] [datetime] NULL CONSTRAINT [cn_wdRun] DEFAULT ('19000101'),
[ScheduleID] [int] NULL CONSTRAINT [cn_wdSchedule] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogItem] ADD CONSTRAINT [PK_Metric_WatchDog] PRIMARY KEY CLUSTERED ([WatchName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogItem] ADD CONSTRAINT [UNQ_wdName_SN] UNIQUE NONCLUSTERED ([sn], [WatchName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogItem] ADD CONSTRAINT [FK_WDScheduleID] FOREIGN KEY ([ScheduleID]) REFERENCES [dbo].[WatchDogScheduleObject] ([ID])
GO
GRANT DELETE ON  [dbo].[WatchDogItem] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogItem] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogItem] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogItem] TO [public]
GO
