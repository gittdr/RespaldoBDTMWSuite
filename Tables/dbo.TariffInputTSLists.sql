CREATE TABLE [dbo].[TariffInputTSLists]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TariffInputTS_Id] [int] NOT NULL,
[ListName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StringValue] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DecimalValue] [decimal] (19, 6) NULL,
[DateValue] [datetime] NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__TariffInp__LastU__3D56BB6C] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TariffInp__LastU__3E4ADFA5] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSLists] ADD CONSTRAINT [pk_TariffInputTSLists] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TariffInputTSLists_TariffInputTS_Id_ListName] ON [dbo].[TariffInputTSLists] ([TariffInputTS_Id], [ListName]) INCLUDE ([Id], [StringValue], [DecimalValue], [DateValue]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSLists] ADD CONSTRAINT [fk_TariffInputTSLists_TariffInputTS_Id] FOREIGN KEY ([TariffInputTS_Id]) REFERENCES [dbo].[TariffInputTS] ([Id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[TariffInputTSLists] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffInputTSLists] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffInputTSLists] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffInputTSLists] TO [public]
GO
