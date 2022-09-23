CREATE TABLE [dbo].[borrar_operador_valido]
(
[idpersonal] [int] NOT NULL,
[antiguedad] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statelic] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cd_tmw] [int] NULL,
[flota] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[borrar_operador_valido] ADD CONSTRAINT [pk_operadorvalido] PRIMARY KEY NONCLUSTERED ([idpersonal]) ON [PRIMARY]
GO
