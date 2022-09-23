CREATE TABLE [dbo].[splitagentpay_tprrelation]
(
[sap_tprrelation_id] [int] NOT NULL IDENTITY(1, 1),
[tpr_id_executing] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpr_id_selling] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpr_split_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpr_split_amount] [money] NOT NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[splitagentpay_tprrelation] ADD CONSTRAINT [pk_splitagentpay_tprrelation] PRIMARY KEY CLUSTERED ([sap_tprrelation_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[splitagentpay_tprrelation] ADD CONSTRAINT [UX_splitagentpay_tprrelation] UNIQUE NONCLUSTERED ([tpr_id_executing], [tpr_id_selling]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[splitagentpay_tprrelation] TO [public]
GO
GRANT INSERT ON  [dbo].[splitagentpay_tprrelation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[splitagentpay_tprrelation] TO [public]
GO
GRANT SELECT ON  [dbo].[splitagentpay_tprrelation] TO [public]
GO
GRANT UPDATE ON  [dbo].[splitagentpay_tprrelation] TO [public]
GO
