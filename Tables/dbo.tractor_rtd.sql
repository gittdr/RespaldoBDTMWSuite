CREATE TABLE [dbo].[tractor_rtd]
(
[rtd_id] [int] NOT NULL IDENTITY(1, 1),
[rtd_trcid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_payperiod] [datetime] NULL,
[rtd_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_createdt] [datetime] NULL,
[rtd_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_lastupdatedt] [datetime] NULL,
[rtd_pay_ineligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tractor_rtd] ADD CONSTRAINT [pk_rtd_number] PRIMARY KEY CLUSTERED ([rtd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tractor_rtd] TO [public]
GO
GRANT INSERT ON  [dbo].[tractor_rtd] TO [public]
GO
GRANT SELECT ON  [dbo].[tractor_rtd] TO [public]
GO
GRANT UPDATE ON  [dbo].[tractor_rtd] TO [public]
GO
