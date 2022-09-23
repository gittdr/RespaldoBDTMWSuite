CREATE TYPE [dbo].[EstructuraCargaxOrden] AS TABLE
(
[Ai_orden] [int] NULL,
[Av_cmd_code] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_cmd_description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Af_count] [float] NULL,
[Av_countunit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_description_parts] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Af_weight] [float] NULL,
[Av_weightunit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_description_units] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
