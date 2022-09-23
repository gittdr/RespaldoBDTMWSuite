CREATE TABLE [dbo].[LTL_quote_log]
(
[ltq_quote_id] [int] NOT NULL,
[ltq_source] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_datetime] [datetime] NULL,
[ltq_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ltq_ord_qte_datetime] [datetime] NULL,
[ltq_pickup_date] [datetime] NULL,
[ltq_origin_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_dest_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_nmfc_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_weight] [float] NULL,
[ltq_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_accessorials] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ltq_count] [float] NULL,
[ltq_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LTL_quote_log] ADD CONSTRAINT [PK__LTL_quote_log__309CB281] PRIMARY KEY CLUSTERED ([ltq_quote_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ltq_ordhdrnumber] ON [dbo].[LTL_quote_log] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTL_quote_log] TO [public]
GO
GRANT INSERT ON  [dbo].[LTL_quote_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTL_quote_log] TO [public]
GO
GRANT SELECT ON  [dbo].[LTL_quote_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTL_quote_log] TO [public]
GO
