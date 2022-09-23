CREATE TABLE [dbo].[DieselMargin_7Dias]
(
[fechaUpdate] [datetime] NOT NULL,
[gerente] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lpc] [varchar] (17) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flota] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[costodiesel] [money] NULL,
[litros] [money] NULL,
[ingreso] [float] NOT NULL,
[margen] [float] NULL,
[iniciadas] [int] NULL,
[planeadas] [int] NULL,
[completadas] [int] NULL,
[ordenes] [int] NULL,
[kmsordenes] [int] NOT NULL,
[kmsodo] [float] NOT NULL,
[pctfueraruta] [float] NOT NULL,
[expi] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[casetas] [float] NULL
) ON [PRIMARY]
GO
