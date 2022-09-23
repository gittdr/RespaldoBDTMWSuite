CREATE TABLE [dbo].[billto_cmd_billingqty_relations]
(
[billto_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gross_net_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[billto_cmd_billingqty_relations] ADD CONSTRAINT [pk_billto_id_cmd_class] PRIMARY KEY CLUSTERED ([billto_id], [cmd_class]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[billto_cmd_billingqty_relations] TO [public]
GO
GRANT INSERT ON  [dbo].[billto_cmd_billingqty_relations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[billto_cmd_billingqty_relations] TO [public]
GO
GRANT SELECT ON  [dbo].[billto_cmd_billingqty_relations] TO [public]
GO
GRANT UPDATE ON  [dbo].[billto_cmd_billingqty_relations] TO [public]
GO
