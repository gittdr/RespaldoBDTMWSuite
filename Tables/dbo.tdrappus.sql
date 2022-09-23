CREATE TABLE [dbo].[tdrappus]
(
[usuario] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contrasena] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cliente] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[app] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[codigo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tdrappus] ADD CONSTRAINT [PK_tdrappus] PRIMARY KEY CLUSTERED ([codigo]) ON [PRIMARY]
GO
