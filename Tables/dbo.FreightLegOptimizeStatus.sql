CREATE TABLE [dbo].[FreightLegOptimizeStatus]
(
[OptimizeStatusId] [tinyint] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLegOptimizeStatus] ADD CONSTRAINT [PK_FreightLegOptimizeStatus] PRIMARY KEY CLUSTERED ([OptimizeStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FreightLegOptimizeStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightLegOptimizeStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightLegOptimizeStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightLegOptimizeStatus] TO [public]
GO
