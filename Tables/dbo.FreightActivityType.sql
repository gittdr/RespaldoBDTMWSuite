CREATE TABLE [dbo].[FreightActivityType]
(
[FreightActivityId] [smallint] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightActivityType] ADD CONSTRAINT [PK_FreightActivityType] PRIMARY KEY CLUSTERED ([FreightActivityId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FreightActivityType] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightActivityType] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightActivityType] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightActivityType] TO [public]
GO
