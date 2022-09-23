CREATE TABLE [dbo].[MR_ReportingColumns]
(
[rc_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rc_reportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rc_sequence] [int] NULL,
[rc_summaryoption] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rc_username] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rc_displayname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rc_datatype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rc_enablereporttotaling] [bit] NOT NULL CONSTRAINT [DF_MR_ReportingColumns_rc_enablereporttotaling] DEFAULT (0),
[rc_totalingcalctype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rc_charactermultiplier] [float] NULL,
[rc_lastwidth] [int] NULL,
[rc_sampletext] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportingColumns] ADD CONSTRAINT [PK_MR_ReportingColumns] PRIMARY KEY CLUSTERED ([rc_name], [rc_reportname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingColumns] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingColumns] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingColumns] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingColumns] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingColumns] TO [public]
GO
