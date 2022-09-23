CREATE TABLE [dbo].[orderconsolidation]
(
[con_id] [int] NOT NULL IDENTITY(1, 1),
[con_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_count] [decimal] (10, 2) NULL,
[con_countunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_weight] [float] NULL,
[con_weightunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_volume] [float] NULL,
[con_volumeunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_pallets] [float] NULL,
[con_palletunits] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_req_refresh] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[orderconsolidation] ADD CONSTRAINT [PK__ordercon__081B0F1ABC508FF7] PRIMARY KEY CLUSTERED ([con_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[orderconsolidation] TO [public]
GO
GRANT INSERT ON  [dbo].[orderconsolidation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[orderconsolidation] TO [public]
GO
GRANT SELECT ON  [dbo].[orderconsolidation] TO [public]
GO
GRANT UPDATE ON  [dbo].[orderconsolidation] TO [public]
GO
