CREATE TABLE [dbo].[aprecondetail_audit]
(
[header_number] [int] NOT NULL,
[detail_sequence] [int] NOT NULL,
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[vendor_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_invoice_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[equipment_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[original_detail_amount] [money] NOT NULL,
[actual_detail_amount] [money] NOT NULL,
[force_pay_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[short_pay_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[detail_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_dttm] [datetime] NULL,
[audit_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aprecondetail_audit] ADD CONSTRAINT [pk_aprecondetail_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_aprecondetail_audit] ON [dbo].[aprecondetail_audit] ([header_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aprecondetail_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[aprecondetail_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[aprecondetail_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[aprecondetail_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[aprecondetail_audit] TO [public]
GO
