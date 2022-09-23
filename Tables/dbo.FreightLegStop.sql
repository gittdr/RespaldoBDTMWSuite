CREATE TABLE [dbo].[FreightLegStop]
(
[FreightLegStopId] [bigint] NOT NULL IDENTITY(1, 1),
[CompanyId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EarlyDateTime] [datetime2] (3) NULL,
[LateDateTime] [datetime2] (3) NULL,
[stp_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightLegStop] ADD CONSTRAINT [PK_FreightLegStop] PRIMARY KEY CLUSTERED ([FreightLegStopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_FreightLegStop_stp_number] ON [dbo].[FreightLegStop] ([stp_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FreightLegStop] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightLegStop] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightLegStop] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightLegStop] TO [public]
GO
