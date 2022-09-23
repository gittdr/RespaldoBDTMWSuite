CREATE TABLE [dbo].[tblLandmarks]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[LatGrid] [smallint] NULL,
[LongGrid] [smallint] NULL,
[SPLC] [int] NULL,
[PopulationCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnglishCityName] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LatDegrees] [float] NULL,
[LongDegrees] [float] NULL,
[ts] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLandmarks] ADD CONSTRAINT [PK_tblLandmarks_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Grid] ON [dbo].[tblLandmarks] ([LatGrid], [LongGrid], [LatDegrees], [LongDegrees]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NewPopCode] ON [dbo].[tblLandmarks] ([PopulationCode]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Name] ON [dbo].[tblLandmarks] ([State], [EnglishCityName]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblLandmarks] TO [public]
GO
GRANT INSERT ON  [dbo].[tblLandmarks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblLandmarks] TO [public]
GO
GRANT SELECT ON  [dbo].[tblLandmarks] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblLandmarks] TO [public]
GO
