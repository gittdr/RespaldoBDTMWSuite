CREATE TABLE [dbo].[CompanyGainShareThreshold]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateFrom] [datetime2] NOT NULL,
[DateTo] [datetime2] NOT NULL,
[Amount] [money] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime2] NULL,
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime2] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyGainShareThreshold] ADD CONSTRAINT [PK_CompanyGainShareThreshold] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyGainShareThreshold] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyGainShareThreshold] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyGainShareThreshold] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyGainShareThreshold] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyGainShareThreshold] TO [public]
GO
