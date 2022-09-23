CREATE TABLE [dbo].[helpdesk_llamadas]
(
[idLlamada] [int] NOT NULL IDENTITY(1, 1),
[idTicket] [int] NULL,
[fechaInicio] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechaFinal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[monitorista] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[operador] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[helpdesk_llamadas] ADD CONSTRAINT [PK__helpdesk__16ADDA303A5CA9D5] PRIMARY KEY CLUSTERED ([idLlamada]) ON [PRIMARY]
GO
