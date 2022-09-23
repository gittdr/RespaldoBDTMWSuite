CREATE TABLE [dbo].[TractorProyHistory]
(
[Id_tractorFecha] [int] NOT NULL IDENTITY(1, 1),
[trc_number] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_driver] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_status] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL,
[trc_type3] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proyecto] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha_insercion] [datetime] NULL CONSTRAINT [DF_TractorProyHistory_fecha_insercion] DEFAULT (getdate()),
[equipo_colaborativo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TractorProyHistory] ADD CONSTRAINT [PK_TractorProyHistory] PRIMARY KEY CLUSTERED ([Id_tractorFecha]) ON [PRIMARY]
GO
