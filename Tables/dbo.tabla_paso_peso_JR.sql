CREATE TABLE [dbo].[tabla_paso_peso_JR]
(
[consecutivo] [int] NOT NULL IDENTITY(1, 1),
[orden] [int] NULL,
[peso] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tabla_paso_peso_JR] ADD CONSTRAINT [PK__tabla_pa__F6E98427C560475B] PRIMARY KEY CLUSTERED ([consecutivo]) ON [PRIMARY]
GO
