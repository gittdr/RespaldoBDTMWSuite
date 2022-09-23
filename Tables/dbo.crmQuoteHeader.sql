CREATE TABLE [dbo].[crmQuoteHeader]
(
[cqh_id] [int] NOT NULL IDENTITY(1, 1),
[cqh_name] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cqh_description] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cqh_type] [int] NOT NULL CONSTRAINT [df_cqh_type] DEFAULT ((0)),
[cqh_billpay] [int] NOT NULL CONSTRAINT [df_cqh_billpay] DEFAULT ((0)),
[cqh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_billto] DEFAULT ('UNKNOWN'),
[cqh_mastercompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_mastercompany] DEFAULT ('UNKNOWN'),
[cqh_cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cqh_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_carrier] DEFAULT ('UNKNOWN'),
[cqh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_status] DEFAULT ('UNK'),
[cqh_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_revtype1] DEFAULT ('UNK'),
[cqh_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_revtype2] DEFAULT ('UNK'),
[cqh_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_revtype3] DEFAULT ('UNK'),
[cqh_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_revtype4] DEFAULT ('UNK'),
[cqh_trltype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_trltype1] DEFAULT ('UNK'),
[cqh_trltype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_trltype2] DEFAULT ('UNK'),
[cqh_trltype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_trltype3] DEFAULT ('UNK'),
[cqh_trltype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_trltype4] DEFAULT ('UNK'),
[cqh_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_cmd_code] DEFAULT ('UNKNOWN'),
[cqh_cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_cmd_class] DEFAULT ('UNKNOWN'),
[cqh_triptype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_triptype1] DEFAULT ('UNK'),
[cqh_triptype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_triptype2] DEFAULT ('UNK'),
[cqh_triptype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_triptype3] DEFAULT ('UNK'),
[cqh_triptype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_triptype4] DEFAULT ('UNK'),
[cqh_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_othertype1] DEFAULT ('UNK'),
[cqh_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_othertype2] DEFAULT ('UNK'),
[cqh_othertype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_othertype3] DEFAULT ('UNK'),
[cqh_othertype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_othertype4] DEFAULT ('UNK'),
[cqh_mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_mode] DEFAULT ('UNK'),
[cqh_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_currency] DEFAULT ('UNK'),
[cqh_minstops] [int] NOT NULL CONSTRAINT [df_cqh_minstops] DEFAULT ((0)),
[cqh_maxstops] [int] NOT NULL CONSTRAINT [df_cqh_maxstops] DEFAULT ((2147483647)),
[cqh_minweight] [int] NOT NULL CONSTRAINT [df_cqh_minweight] DEFAULT ((0)),
[cqh_maxweight] [int] NOT NULL CONSTRAINT [df_cqh_maxweight] DEFAULT ((2147483647)),
[cqh_wgtunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_wgtunit] DEFAULT ('LBS'),
[cqh_minpieces] [int] NOT NULL CONSTRAINT [df_cqh_minpieces] DEFAULT ((0)),
[cqh_maxpieces] [int] NOT NULL CONSTRAINT [df_cqh_maxpieces] DEFAULT ((2147483647)),
[cqh_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_countunit] DEFAULT ('PCS'),
[cqh_minvolume] [int] NOT NULL CONSTRAINT [df_cqh_minvolume] DEFAULT ((0)),
[cqh_maxvolume] [int] NOT NULL CONSTRAINT [df_cqh_maxvolume] DEFAULT ((2147483647)),
[cqh_volunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_volunit] DEFAULT ('GAL'),
[cqh_minmiles] [int] NOT NULL CONSTRAINT [df_cqh_minmiles] DEFAULT ((0)),
[cqh_maxmiles] [int] NOT NULL CONSTRAINT [df_cqh_maxmiles] DEFAULT ((2147483647)),
[cqh_distunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_distunit] DEFAULT ('MIL'),
[cqh_minodmiles] [int] NOT NULL CONSTRAINT [df_cqh_minodmiles] DEFAULT ((0)),
[cqh_maxodmiles] [int] NOT NULL CONSTRAINT [df_cqh_maxodmiles] DEFAULT ((2147483647)),
[cqh_odunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cqh_odunit] DEFAULT ('MIL'),
[cqh_minvariance] [int] NOT NULL CONSTRAINT [df_cqh_minvariance] DEFAULT ((0)),
[cqh_maxvariance] [int] NOT NULL CONSTRAINT [df_cqh_maxvariance] DEFAULT ((2147483647)),
[cqh_mincarriersvcdays] [int] NOT NULL CONSTRAINT [df_cqh_mincarriersvcdays] DEFAULT ((0)),
[cqh_maxcarriersvcdays] [int] NOT NULL CONSTRAINT [df_cqh_maxcarriersvcdays] DEFAULT ((2147483647)),
[cqh_minlength] [int] NOT NULL CONSTRAINT [df_cqh_minlength] DEFAULT ((0)),
[cqh_maxlength] [int] NOT NULL CONSTRAINT [df_cqh_maxlength] DEFAULT ((2147483647)),
[cqh_minwidth] [int] NOT NULL CONSTRAINT [df_cqh_minwidth] DEFAULT ((0)),
[cqh_maxwidth] [int] NOT NULL CONSTRAINT [df_cqh_maxwidth] DEFAULT ((2147483647)),
[cqh_minheight] [int] NOT NULL CONSTRAINT [df_cqh_minheight] DEFAULT ((0)),
[cqh_maxheight] [int] NOT NULL CONSTRAINT [df_cqh_maxheight] DEFAULT ((2147483647)),
[cqh_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cqh_createdon] [datetime] NULL,
[cqh_sentforrates] [datetime] NULL,
[cqh_ratequotecomplete] [datetime] NULL,
[cqh_tar_number_group] [int] NULL,
[cqh_billto_table] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crmQuoteHeader] ADD CONSTRAINT [pk_cqh_id] PRIMARY KEY CLUSTERED ([cqh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[crmQuoteHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[crmQuoteHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[crmQuoteHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[crmQuoteHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[crmQuoteHeader] TO [public]
GO
