CREATE TABLE [dbo].[AvgFuelFormulaCriteria]
(
[aff_id] [int] NOT NULL IDENTITY(1, 1),
[afp_tableid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[afp_Description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[aff_formula_tableid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[aff_Interval] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aff_CycleDay] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aff_Formula] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aff_formula_Acronym] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aff_formula_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aff_effective_day1] [int] NULL,
[aff_effective_day2] [int] NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[aff_effective_dt] [datetime] NULL,
[aff_BackFillCreated] [int] NULL CONSTRAINT [DF__AvgFuelFo__aff_B__069758E2] DEFAULT ((0)),
[afp_CalcPriceUsingDOW] [int] NULL CONSTRAINT [DF__AvgFuelFo__afp_C__078B7D1B] DEFAULT ((0)),
[aff_effective_doe_date] [int] NULL,
[aff_start_day] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AvgFuelFormulaCriteria] ADD CONSTRAINT [pk_aff_id] PRIMARY KEY CLUSTERED ([aff_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AvgFuelFormulaCriteria] TO [public]
GO
GRANT INSERT ON  [dbo].[AvgFuelFormulaCriteria] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AvgFuelFormulaCriteria] TO [public]
GO
GRANT SELECT ON  [dbo].[AvgFuelFormulaCriteria] TO [public]
GO
GRANT UPDATE ON  [dbo].[AvgFuelFormulaCriteria] TO [public]
GO
