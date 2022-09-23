CREATE TABLE [dbo].[TMSMatrix]
(
[MatrixId] [int] NOT NULL IDENTITY(1, 1),
[TariffNumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TariffItem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivd_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[cht_currunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivd_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number_group] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrix] ADD CONSTRAINT [PK_TMSMatrix] PRIMARY KEY CLUSTERED ([MatrixId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSMatrix] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSMatrix] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSMatrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSMatrix] TO [public]
GO
