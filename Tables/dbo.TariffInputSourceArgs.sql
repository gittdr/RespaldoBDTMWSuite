CREATE TABLE [dbo].[TariffInputSourceArgs]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TariffInputSource_id] [int] NOT NULL,
[InputVariable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InputDataType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MappedVariable] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__TariffInp__LastU__2AB3F69F] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TariffInp__LastU__2BA81AD8] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputSourceArgs] ADD CONSTRAINT [pk_TariffInputSourceArgs] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TariffInputSourceArgs_TariffInputSource_id] ON [dbo].[TariffInputSourceArgs] ([TariffInputSource_id]) INCLUDE ([Id], [InputVariable], [InputDataType], [MappedVariable], [Description]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputSourceArgs] ADD CONSTRAINT [fk_TariffInputSourceargs_TariffInputSource_id] FOREIGN KEY ([TariffInputSource_id]) REFERENCES [dbo].[TariffInputSource] ([Id])
GO
GRANT DELETE ON  [dbo].[TariffInputSourceArgs] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffInputSourceArgs] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffInputSourceArgs] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffInputSourceArgs] TO [public]
GO
