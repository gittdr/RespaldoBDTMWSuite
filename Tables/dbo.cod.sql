CREATE TABLE [dbo].[cod]
(
[ord_hdrnumber] [int] NOT NULL,
[cod_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cod_amount] [money] NULL,
[cod_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fee_terms] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[check_num] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cod_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[received_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_city] [int] NULL,
[mailto_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_on] [datetime] NULL,
[mailto_method] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailto_tracking] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[cod_inv_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fee_inv_status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[branch_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legalentity_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cod] ADD CONSTRAINT [PK__cod__68673FEF0B110F8B] PRIMARY KEY CLUSTERED ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cod] TO [public]
GO
GRANT INSERT ON  [dbo].[cod] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cod] TO [public]
GO
GRANT SELECT ON  [dbo].[cod] TO [public]
GO
GRANT UPDATE ON  [dbo].[cod] TO [public]
GO
