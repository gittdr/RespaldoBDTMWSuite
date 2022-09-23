CREATE TABLE [dbo].[TrailerZoneTemperature]
(
[tzt_identity] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NOT NULL,
[tzt_trailersequence] [int] NOT NULL,
[tzt_zone] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tzt_runat] [int] NOT NULL,
[tzt_lastreportedtemp] [int] NULL,
[tzt_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tzt_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tzt_updated] [datetime] NULL,
[tzt_runat_high] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrailerZoneTemperature] ADD CONSTRAINT [PK_TrailerZoneTemperature] PRIMARY KEY CLUSTERED ([tzt_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrailerZoneTemperature] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerZoneTemperature] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerZoneTemperature] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerZoneTemperature] TO [public]
GO
