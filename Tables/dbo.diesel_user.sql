CREATE TABLE [dbo].[diesel_user]
(
[Usuario] [nchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pass] [varbinary] (128) NOT NULL,
[aplicacion] [int] NULL,
[descripcion] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[diesel_user] ADD CONSTRAINT [PK__diesel_user__2E194444] PRIMARY KEY CLUSTERED ([Usuario]) ON [PRIMARY]
GO
