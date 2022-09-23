CREATE TABLE [dbo].[cancelarcporte]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[Folio] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Motivo] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL CONSTRAINT [DF__cancelarc__fecha__02B21CF9] DEFAULT (getdate())
) ON [PRIMARY]
GO
