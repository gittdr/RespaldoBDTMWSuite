CREATE TABLE [dbo].[tts_bs_ontime]
(
[Cliente] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proyecto] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lider] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Eventos] [int] NULL,
[CMPOntime] [int] NULL,
[CMPLate] [int] NULL,
[ontimeh] [int] NULL,
[riskh] [int] NULL,
[lateh] [int] NULL,
[nocal] [int] NULL,
[ontime>1] [int] NULL,
[risk>1] [int] NULL,
[late>1] [int] NULL,
[nocal>1] [int] NULL
) ON [PRIMARY]
GO
