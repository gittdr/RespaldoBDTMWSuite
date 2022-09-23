CREATE TABLE [dbo].[paydetaildefaults]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pdd_quantity] [decimal] (18, 4) NULL,
[pdd_rate] [decimal] (18, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paydetaildefaults] ADD CONSTRAINT [PK_paydetaildefaults] PRIMARY KEY CLUSTERED ([brn_id], [lgh_type1], [mpp_type1], [pyt_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetaildefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetaildefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetaildefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetaildefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetaildefaults] TO [public]
GO
