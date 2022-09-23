CREATE TABLE [dbo].[temporal]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Ai_orden] [int] NULL,
[Av_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_cmd_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Af_count] [float] NULL,
[Av_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_description_parts] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Af_weight] [float] NULL,
[Av_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Av_description_units] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[temporal] ADD CONSTRAINT [PK__temporal__3213E83FE18DEEB1] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
