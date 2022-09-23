CREATE TABLE [dbo].[TariffInputSource]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__TariffInp__LastU__26E365BB] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TariffInp__LastU__27D789F4] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputSource] ADD CONSTRAINT [pk_TariffInputSource] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_TariffInputSource_Abbr] ON [dbo].[TariffInputSource] ([Abbr]) INCLUDE ([Id], [Name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TariffInputSource] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffInputSource] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffInputSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffInputSource] TO [public]
GO
