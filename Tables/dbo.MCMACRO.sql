CREATE TABLE [dbo].[MCMACRO]
(
[MCT_SERVICE] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCT_NAME] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCT_DIRECTION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCT_MACRONUM] [smallint] NOT NULL,
[MCT_MACROVER] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_REPLYMACRO] [smallint] NULL,
[MCT_AVAILABLE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_SYSTEMMACRO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_STATUSMESSAGE] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_MACROTYPE] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_servdirmacnum] ON [dbo].[MCMACRO] ([MCT_SERVICE], [MCT_DIRECTION], [MCT_MACRONUM]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MCMACRO] TO [public]
GO
GRANT INSERT ON  [dbo].[MCMACRO] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MCMACRO] TO [public]
GO
GRANT SELECT ON  [dbo].[MCMACRO] TO [public]
GO
GRANT UPDATE ON  [dbo].[MCMACRO] TO [public]
GO
