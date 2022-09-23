CREATE TABLE [dbo].[TMSAreaDetail]
(
[AreaId] [int] NOT NULL IDENTITY(1, 1),
[RegId] [int] NULL,
[Company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [int] NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawData] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAreaDetail] ADD CONSTRAINT [PK_TMSAreaDetail] PRIMARY KEY CLUSTERED ([AreaId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAreaDetail] ADD CONSTRAINT [FK_TMSAreaDetail_City] FOREIGN KEY ([City]) REFERENCES [dbo].[city] ([cty_code])
GO
ALTER TABLE [dbo].[TMSAreaDetail] ADD CONSTRAINT [FK_TMSAreaDetail_Company] FOREIGN KEY ([Company]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSAreaDetail] ADD CONSTRAINT [FK_TMSAreaDetail_RegId] FOREIGN KEY ([RegId]) REFERENCES [dbo].[TMSRegion] ([RegId])
GO
GRANT DELETE ON  [dbo].[TMSAreaDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSAreaDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSAreaDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSAreaDetail] TO [public]
GO
