CREATE TABLE [dbo].[ltsl_freightdetail]
(
[fgt_number] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_weight] [float] NULL,
[fgt_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[fgt_count] [int] NULL,
[fgt_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume] [float] NULL,
[fgt_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_lowtemp] [smallint] NULL,
[fgt_hitemp] [smallint] NULL,
[fgt_sequence] [smallint] NULL,
[fgt_length] [float] NULL,
[fgt_lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_height] [float] NULL,
[fgt_heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_width] [float] NULL,
[fgt_widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[fgt_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_quantity] [float] NULL,
[fgt_rate] [money] NULL,
[fgt_charge] [money] NULL,
[fgt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skip_trigger] [tinyint] NULL,
[tare_weight] [float] NULL,
[tare_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltsl_freightdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[ltsl_freightdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltsl_freightdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[ltsl_freightdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltsl_freightdetail] TO [public]
GO
