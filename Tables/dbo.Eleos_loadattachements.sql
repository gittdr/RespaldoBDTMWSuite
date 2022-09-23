CREATE TABLE [dbo].[Eleos_loadattachements]
(
[attachid] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[attachment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Eleos_loadattachements] ADD CONSTRAINT [PK_Eleos_loadattachements] PRIMARY KEY CLUSTERED ([attachid], [attachment]) ON [PRIMARY]
GO
