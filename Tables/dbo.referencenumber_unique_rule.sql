CREATE TABLE [dbo].[referencenumber_unique_rule]
(
[rur_rule] [int] NOT NULL IDENTITY(1, 1),
[rur_billtoid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_referencenumber_unique_rule_rnur_billtoid] DEFAULT ('UNKNOWN'),
[rur_shipperid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_referencenumber_unique_rule_rnur_shipperid] DEFAULT ('UNKNOWN'),
[rur_consigneeid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_referencenumber_unique_rule_rnur_consigneeid] DEFAULT ('UNKNOWN'),
[rur_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_referencenumber_unique_rule_rnur_reftype] DEFAULT ('UNK'),
[rur_level] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_referencenumber_unique_rule_rnur_level] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[referencenumber_unique_rule] ADD CONSTRAINT [pk_referencenumber_unique_rule] PRIMARY KEY CLUSTERED ([rur_billtoid], [rur_shipperid], [rur_consigneeid], [rur_reftype], [rur_level]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[referencenumber_unique_rule] TO [public]
GO
GRANT INSERT ON  [dbo].[referencenumber_unique_rule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[referencenumber_unique_rule] TO [public]
GO
GRANT SELECT ON  [dbo].[referencenumber_unique_rule] TO [public]
GO
GRANT UPDATE ON  [dbo].[referencenumber_unique_rule] TO [public]
GO
