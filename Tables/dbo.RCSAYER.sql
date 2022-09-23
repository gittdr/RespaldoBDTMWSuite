CREATE TABLE [dbo].[RCSAYER]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[usuario] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[narchivo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NOT NULL CONSTRAINT [DF__RCSAYER__fecha__6ADA9368] DEFAULT (getdate()),
[Estatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RCSAYER] ADD CONSTRAINT [PK__RCSAYER__6E4DA4BEE97ACCE5] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
