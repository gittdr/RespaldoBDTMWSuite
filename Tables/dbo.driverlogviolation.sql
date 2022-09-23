CREATE TABLE [dbo].[driverlogviolation]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drl_month] [smallint] NOT NULL,
[drl_year] [smallint] NOT NULL,
[drl_mph] [smallint] NULL,
[drl_hr10] [smallint] NULL,
[drl_hr15] [smallint] NULL,
[drl_hr70] [smallint] NULL,
[drl_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[drl_id] [int] NOT NULL IDENTITY(1, 1),
[drl_date] [datetime] NULL,
[ViolationCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_level] [int] NULL,
[drl_ignore] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_updatedate] [datetime] NULL,
[drl_settledcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_settledby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_settleddate] [datetime] NULL,
[drl_ignorecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_ignoreby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drl_ignoredate] [datetime] NULL,
[drl_comment2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driverlogviolation] ADD CONSTRAINT [pk_driverlogviolation] PRIMARY KEY CLUSTERED ([drl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_driverlogviolation_iym] ON [dbo].[driverlogviolation] ([mpp_id], [drl_year], [drl_month]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driverlogviolation] ADD CONSTRAINT [FK_driverlogviolation_DriverLogViolationType] FOREIGN KEY ([ViolationCode]) REFERENCES [dbo].[DriverLogViolationType] ([ViolationCode])
GO
GRANT DELETE ON  [dbo].[driverlogviolation] TO [public]
GO
GRANT INSERT ON  [dbo].[driverlogviolation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverlogviolation] TO [public]
GO
GRANT SELECT ON  [dbo].[driverlogviolation] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverlogviolation] TO [public]
GO
