CREATE TABLE [dbo].[FreightOrderStop]
(
[FreightOrderStopId] [bigint] NOT NULL IDENTITY(1, 1),
[LocationKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EarlyDateTime] [datetime2] (3) NULL,
[LateDateTime] [datetime2] (3) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderStop] ADD CONSTRAINT [PK_FreightOrderStop] PRIMARY KEY CLUSTERED ([FreightOrderStopId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FreightOrderStop] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderStop] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderStop] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderStop] TO [public]
GO
