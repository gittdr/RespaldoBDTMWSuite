CREATE TABLE [dbo].[TractorPlanLayout]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[sortorder] [tinyint] NOT NULL,
[detail] [tinyint] NOT NULL CONSTRAINT [DF_TractorPlanLayout_detail] DEFAULT (0),
[field] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[label] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[displaylabel] [tinyint] NOT NULL CONSTRAINT [DF_TractorPlanLayout_displaylabel] DEFAULT (0),
[startingposition] [smallint] NOT NULL CONSTRAINT [DF_TractorPlanLayout_startingposition] DEFAULT (1),
[numbercharacters] [smallint] NOT NULL CONSTRAINT [DF_TractorPlanLayout_numbercharacters] DEFAULT (999)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_field] ON [dbo].[TractorPlanLayout] ([field]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TractorPlanLayout] TO [public]
GO
GRANT INSERT ON  [dbo].[TractorPlanLayout] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TractorPlanLayout] TO [public]
GO
GRANT SELECT ON  [dbo].[TractorPlanLayout] TO [public]
GO
GRANT UPDATE ON  [dbo].[TractorPlanLayout] TO [public]
GO
