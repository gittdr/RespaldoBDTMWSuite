CREATE TABLE [dbo].[tabla_paso_aguinaldo_JR]
(
[ID_consecutivo] [int] NOT NULL,
[ID_operador] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID_concepto] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID_Monto] [money] NULL,
[ID_Descripcion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tabla_paso_aguinaldo_JR] ADD CONSTRAINT [PK__tabla_pa__582629212F8DFC22] PRIMARY KEY CLUSTERED ([ID_consecutivo]) ON [PRIMARY]
GO
