CREATE TABLE [dbo].[cierrehd]
(
[ORDEN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REFERENCIA] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FECHA INICIO] [datetime] NULL,
[iniciovacio IBMT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iniciocargado HPL,LLD] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destino LUL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[termina IEMT,IEBT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMS CARGADOS] [float] NULL,
[KMS VACIOS] [float] NULL,
[KMS TOTALES] [float] NULL,
[PEAJE] [float] NULL,
[PEAJE2] [float] NULL,
[TOTAL PEAJE] [float] NULL,
[PROV SAP/TARIFA] [float] NULL,
[CIUDAD] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPO DE VIAJE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ESTATUS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACTURA] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cierrehd] ADD CONSTRAINT [PK_cierrehd] PRIMARY KEY CLUSTERED ([ORDEN]) ON [PRIMARY]
GO
