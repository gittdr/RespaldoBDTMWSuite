CREATE TABLE [dbo].[commodity_equivalent]
(
[EqId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_equivalent] ADD CONSTRAINT [PK__commodity_equiva__05A3D265] PRIMARY KEY CLUSTERED ([EqId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_equivalent] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_equivalent] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_equivalent] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_equivalent] TO [public]
GO
