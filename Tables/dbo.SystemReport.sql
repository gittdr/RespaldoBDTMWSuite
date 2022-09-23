CREATE TABLE [dbo].[SystemReport]
(
[SystemReportId] [int] NOT NULL IDENTITY(1, 1),
[ReportUrl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__SystemRep__Creat__7AC1BEFF] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__SystemRep__Creat__7BB5E338] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__SystemRep__LastU__7CAA0771] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__SystemRep__LastU__7D9E2BAA] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemReport] ADD CONSTRAINT [PK_dbo.SystemReport] PRIMARY KEY CLUSTERED ([SystemReportId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SystemReport] TO [public]
GO
GRANT INSERT ON  [dbo].[SystemReport] TO [public]
GO
GRANT SELECT ON  [dbo].[SystemReport] TO [public]
GO
GRANT UPDATE ON  [dbo].[SystemReport] TO [public]
GO
