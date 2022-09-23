CREATE TABLE [dbo].[LegOdLocation]
(
[LegOdId] [int] NOT NULL IDENTITY(1, 1),
[CreatedDate] [datetime2] NOT NULL,
[ExportDate] [datetime2] NULL,
[ExportKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginLocationKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationLocationKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LegOdLocation] ADD CONSTRAINT [PK_LegOdLocation] PRIMARY KEY CLUSTERED ([LegOdId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_OriginLocationKey_DestinationLocationKey] ON [dbo].[LegOdLocation] ([OriginLocationKey], [DestinationLocationKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LegOdLocation] TO [public]
GO
GRANT INSERT ON  [dbo].[LegOdLocation] TO [public]
GO
GRANT SELECT ON  [dbo].[LegOdLocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[LegOdLocation] TO [public]
GO
