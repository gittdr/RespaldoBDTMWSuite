CREATE TABLE [dbo].[tempcargos]
(
[toh_ordernumber] [int] NOT NULL,
[ts_sequence] [int] NULL,
[tc_sequence] [int] NULL,
[tc_quantity] [float] NULL,
[tc_quantityunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_weight] [float] NULL,
[tc_weightunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_volume] [float] NULL,
[tc_volumeunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_rate] [money] NULL,
[tc_rateunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_description] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_tstampq] [int] NULL,
[tc_charge] [money] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_count] [int] NULL,
[tc_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tc_chargetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_key] ON [dbo].[tempcargos] ([toh_tstampq], [toh_ordernumber], [ts_sequence], [tc_sequence]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempcargos] ADD CONSTRAINT [FK_cmd_code] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
GRANT DELETE ON  [dbo].[tempcargos] TO [public]
GO
GRANT INSERT ON  [dbo].[tempcargos] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tempcargos] TO [public]
GO
GRANT SELECT ON  [dbo].[tempcargos] TO [public]
GO
GRANT UPDATE ON  [dbo].[tempcargos] TO [public]
GO
