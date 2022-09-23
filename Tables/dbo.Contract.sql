CREATE TABLE [dbo].[Contract]
(
[contract_id] [numeric] (18, 0) NOT NULL IDENTITY(1, 1),
[route_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contract_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__contra__2847CB65] DEFAULT (1),
[contract_rate] [decimal] (19, 4) NOT NULL,
[uom] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__uom__293BEF9E] DEFAULT ('CWT'),
[add_pct] [numeric] (18, 0) NOT NULL CONSTRAINT [DF__Contract__add_pc__2A3013D7] DEFAULT (0),
[or_charge] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__or_cha__2B243810] DEFAULT (0),
[adjlane_cost] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__adjlan__2C185C49] DEFAULT (0),
[no_freight_charge] [decimal] (19, 4) NOT NULL,
[fuel_sc_exempt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__fuel_s__2D0C8082] DEFAULT ('N'),
[calculate_fuel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__calcul__2E00A4BB] DEFAULT ('Y'),
[detail_min_charge] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__detail__2EF4C8F4] DEFAULT (0),
[detail_max_charge] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__detail__2FE8ED2D] DEFAULT (0),
[fixed_cwt] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__fixed___30DD1166] DEFAULT (0),
[min_cwt] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__min_cw__31D1359F] DEFAULT (0),
[max_cwt] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__max_cw__32C559D8] DEFAULT (0),
[credit_back_percent] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__credit__33B97E11] DEFAULT (0),
[credit_back_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__credit__34ADA24A] DEFAULT ('N'),
[fixed_cost] [decimal] (19, 4) NOT NULL CONSTRAINT [DF__Contract__fixed___35A1C683] DEFAULT (0),
[ord_hdrnumber] [numeric] (18, 0) NOT NULL,
[mastord_hdrnumber] [numeric] (18, 0) NOT NULL,
[ar_arrangement] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Contract__ar_arr__3695EABC] DEFAULT (1),
[bill_fuel_seperate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fsc_rate_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_contract_mastord_hdrnumber] ON [dbo].[Contract] ([mastord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_contract_ord_hdrnumber] ON [dbo].[Contract] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Contract] TO [public]
GO
GRANT INSERT ON  [dbo].[Contract] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Contract] TO [public]
GO
GRANT SELECT ON  [dbo].[Contract] TO [public]
GO
GRANT UPDATE ON  [dbo].[Contract] TO [public]
GO
