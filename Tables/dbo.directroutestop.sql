CREATE TABLE [dbo].[directroutestop]
(
[drs_id] [int] NOT NULL IDENTITY(1, 1),
[drh_id] [int] NULL,
[stp_number] [int] NOT NULL,
[drs_routedLegNum] [int] NULL,
[drs_routedtruck] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drs_routedarrival] [datetime] NULL,
[drs_routeddeparture] [datetime] NULL,
[drs_routeddistance] [decimal] (9, 1) NULL,
[drs_routedsequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[directroutestop] ADD CONSTRAINT [PK__directroutestop__185B149C] PRIMARY KEY CLUSTERED ([drs_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[directroutestop] TO [public]
GO
GRANT INSERT ON  [dbo].[directroutestop] TO [public]
GO
GRANT REFERENCES ON  [dbo].[directroutestop] TO [public]
GO
GRANT SELECT ON  [dbo].[directroutestop] TO [public]
GO
GRANT UPDATE ON  [dbo].[directroutestop] TO [public]
GO
