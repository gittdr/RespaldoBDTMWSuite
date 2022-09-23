CREATE TABLE [dbo].[TrailerOptimalWeight]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[tow_Country] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tow_TrailerType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tow_Weight] [int] NULL,
[tow_UOM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tow_Retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tow_LastUpdatedDate] [datetime] NULL,
[tow_LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [TrailerOptimalWeight_PK] ON [dbo].[TrailerOptimalWeight] ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TrailerOptimalWeight_CountryTrailerType] ON [dbo].[TrailerOptimalWeight] ([tow_Country], [tow_TrailerType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrailerOptimalWeight] TO [public]
GO
GRANT INSERT ON  [dbo].[TrailerOptimalWeight] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrailerOptimalWeight] TO [public]
GO
GRANT SELECT ON  [dbo].[TrailerOptimalWeight] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrailerOptimalWeight] TO [public]
GO
