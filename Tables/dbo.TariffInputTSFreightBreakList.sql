CREATE TABLE [dbo].[TariffInputTSFreightBreakList]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[TariffInputTS_Id] [int] NOT NULL,
[tar_tablebreak_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [decimal] (19, 6) NULL,
[count] [decimal] (19, 6) NULL,
[volume] [decimal] (19, 6) NULL,
[length] [decimal] (19, 6) NULL,
[width] [decimal] (19, 6) NULL,
[height] [decimal] (19, 6) NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__TariffInp__LastU__421B7089] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TariffInp__LastU__430F94C2] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSFreightBreakList] ADD CONSTRAINT [pk_TariffInputTSFreightBreakList] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TariffInputTSFreightBreakList_TariffInputTS_Id] ON [dbo].[TariffInputTSFreightBreakList] ([TariffInputTS_Id]) INCLUDE ([Id], [weight], [count], [volume], [length], [width], [height]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TariffInputTSFreightBreakList] ADD CONSTRAINT [fk_TariffInputTSFreightBreakList_TariffInputTS_Id] FOREIGN KEY ([TariffInputTS_Id]) REFERENCES [dbo].[TariffInputTS] ([Id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[TariffInputTSFreightBreakList] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffInputTSFreightBreakList] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffInputTSFreightBreakList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffInputTSFreightBreakList] TO [public]
GO
