CREATE TABLE [dbo].[company_hourswindow]
(
[chw_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WindowType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WindowDay] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WindowStart] [datetime] NOT NULL,
[WindowEnd] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_hourswindow] ADD CONSTRAINT [PK__company_hourswin__362CD389] PRIMARY KEY CLUSTERED ([chw_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_hourswindow] TO [public]
GO
GRANT INSERT ON  [dbo].[company_hourswindow] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_hourswindow] TO [public]
GO
GRANT SELECT ON  [dbo].[company_hourswindow] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_hourswindow] TO [public]
GO
