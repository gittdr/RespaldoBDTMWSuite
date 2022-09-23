CREATE TABLE [dbo].[tts_bs_invoice]
(
[Cliente] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ordenes] [int] NULL,
[Monto] [float] NULL,
[Lag] [int] NULL,
[AVLCount] [int] NULL,
[AVLMonto] [float] NULL,
[AVLPerc] [float] NULL,
[AVLLag] [int] NULL,
[HLDCount] [int] NULL,
[HLDMonto] [float] NULL,
[HLDPerc] [float] NULL,
[HLDLag] [int] NULL,
[RTPCount] [int] NULL,
[RTPMonto] [float] NULL,
[RTPPerc] [float] NULL,
[RTPLag] [float] NULL,
[PRNCount] [int] NULL,
[PRNMonto] [float] NULL,
[PRNPerc] [float] NULL,
[PRNLag] [int] NULL,
[HLACount] [int] NULL,
[HLAMonto] [float] NULL,
[HLAPerc] [float] NULL,
[HLALag] [int] NULL
) ON [PRIMARY]
GO
