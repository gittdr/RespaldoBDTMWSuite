CREATE TABLE [dbo].[vale_complemento_A1]
(
[num_vale_A1] [int] NOT NULL,
[vale_id_motivo_A1] [int] NULL,
[vale_proyecto_A1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vale_observaciones_A1] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creo_vale] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vale_complemento_A1] ADD CONSTRAINT [PK__vale_com__4761C1AFDACD0961] PRIMARY KEY CLUSTERED ([num_vale_A1]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vale_complemento_A1] ADD CONSTRAINT [FK__vale_comp__vale___49DD5D68] FOREIGN KEY ([vale_id_motivo_A1]) REFERENCES [dbo].[vale_complemento_motivo] ([id_motivo])
GO
