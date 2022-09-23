CREATE TABLE [dbo].[ida_IDAEval]
(
[idIDAEval] [int] NOT NULL IDENTITY(1, 1),
[iOrder] [int] NOT NULL,
[sEvalName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sDescription] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fEnabled] [bit] NULL,
[sFilename] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sClassName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iDisplayOrder] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ida_IDAEval] ADD CONSTRAINT [PK_ida_IDAEval] PRIMARY KEY CLUSTERED ([idIDAEval]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ida_IDAEval] TO [public]
GO
GRANT INSERT ON  [dbo].[ida_IDAEval] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ida_IDAEval] TO [public]
GO
GRANT SELECT ON  [dbo].[ida_IDAEval] TO [public]
GO
GRANT UPDATE ON  [dbo].[ida_IDAEval] TO [public]
GO
