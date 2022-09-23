CREATE TABLE [dbo].[driver_plan]
(
[drvplan_number] [int] NOT NULL,
[drvplan_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvplan_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvplan_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvplan_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driver_plan] TO [public]
GO
GRANT INSERT ON  [dbo].[driver_plan] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driver_plan] TO [public]
GO
GRANT SELECT ON  [dbo].[driver_plan] TO [public]
GO
GRANT UPDATE ON  [dbo].[driver_plan] TO [public]
GO
