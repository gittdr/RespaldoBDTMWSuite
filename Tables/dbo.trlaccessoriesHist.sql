CREATE TABLE [dbo].[trlaccessoriesHist]
(
[ta_type_h] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_trailer_h] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_fecha_h] [datetime] NULL,
[ta_quantity_ant_h] [int] NULL,
[ta_quantity_h] [int] NULL,
[ta_source_h] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_usuario_h] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
