CREATE TABLE [dbo].[apreconheader_audit]
(
[header_number] [int] NOT NULL,
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[vendor_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_invoice_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_invoice_date] [datetime] NOT NULL,
[ap_total_invoice_amount] [money] NOT NULL,
[vendor_location] [tinyint] NOT NULL,
[rail_motor_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[header_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_source] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[matched_to_extract] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_dttm] [datetime] NULL,
[audit_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apreconheader_audit] ADD CONSTRAINT [pk_apreconheader_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_apreconheader_audit] ON [dbo].[apreconheader_audit] ([header_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[apreconheader_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[apreconheader_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[apreconheader_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[apreconheader_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[apreconheader_audit] TO [public]
GO
