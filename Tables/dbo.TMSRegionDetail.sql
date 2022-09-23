CREATE TABLE [dbo].[TMSRegionDetail]
(
[RegDetId] [int] NOT NULL IDENTITY(1, 1),
[RegId] [int] NOT NULL,
[City] [int] NULL,
[State] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawData] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRegionDetail] ADD CONSTRAINT [PK_TMSRegionDetail] PRIMARY KEY CLUSTERED ([RegDetId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSRegionDetail_RegId] ON [dbo].[TMSRegionDetail] ([RegId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRegionDetail] ADD CONSTRAINT [FK_TMSRegionDetail_RegId] FOREIGN KEY ([RegId]) REFERENCES [dbo].[TMSRegion] ([RegId])
GO
GRANT DELETE ON  [dbo].[TMSRegionDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSRegionDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSRegionDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSRegionDetail] TO [public]
GO
