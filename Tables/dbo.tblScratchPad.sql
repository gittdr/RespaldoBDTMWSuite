CREATE TABLE [dbo].[tblScratchPad]
(
[DateIns] [datetime] NULL CONSTRAINT [DF__tblScratc__DateI__52BE253F] DEFAULT (getdate()),
[DateUpd] [datetime] NULL CONSTRAINT [DF__tblScratc__DateU__53B24978] DEFAULT (getdate()),
[Type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeValue] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Key1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Key1Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
