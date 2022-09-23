CREATE TABLE [dbo].[tblGenericReeferUnitTypes]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mode0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mode7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtMode0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtMode1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtMode2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtMode3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secondary7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sensor0] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sensor1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Setpoint] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGenericReeferUnitTypes] ADD CONSTRAINT [PK_tblGenericReeferUnitTypes] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblGenericReeferUnitTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[tblGenericReeferUnitTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblGenericReeferUnitTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[tblGenericReeferUnitTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblGenericReeferUnitTypes] TO [public]
GO
