CREATE TABLE [dbo].[tariffextparameters]
(
[tar_number] [int] NOT NULL,
[tep_tariff_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tep_weight_break_discount1] [decimal] (4, 2) NULL,
[tep_weight_break_discount2] [decimal] (4, 2) NULL,
[tep_weight_break_discount3] [decimal] (4, 2) NULL,
[tep_weight_break_discount4] [decimal] (4, 2) NULL,
[tep_weight_break_discount5] [decimal] (4, 2) NULL,
[tep_weight_break_discount6] [decimal] (4, 2) NULL,
[tep_weight_break_discount7] [decimal] (4, 2) NULL,
[tep_weight_break_discount8] [decimal] (4, 2) NULL,
[tep_weight_break_discount9] [decimal] (4, 2) NULL,
[tep_weight_break_discount10] [decimal] (4, 2) NULL,
[tep_weight_break_discount11] [decimal] (4, 2) NULL,
[tep_max_alternation_weight] [int] NULL,
[tep_discount_application_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tep_rate_adjustment_factor] [decimal] (5, 4) NULL,
[tep_surcharge_percent_ltl] [decimal] (4, 2) NULL,
[tep_surcharge_percent_tl] [decimal] (4, 2) NULL,
[tep_surcharge_application_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tep_mcdiscount] [decimal] (4, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffextparameters] ADD CONSTRAINT [PK__tariffextparamet__1457A9C9] PRIMARY KEY CLUSTERED ([tar_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffextparameters] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffextparameters] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffextparameters] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffextparameters] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffextparameters] TO [public]
GO
