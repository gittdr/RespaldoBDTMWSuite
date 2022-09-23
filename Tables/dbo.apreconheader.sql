CREATE TABLE [dbo].[apreconheader]
(
[header_number] [int] NOT NULL,
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
[matched_to_extract] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[dt_apreconheader] on [dbo].[apreconheader] for delete as
begin
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	Insert into apreconheader_audit
	(header_number,	
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	audit_user,
	audit_dttm,
	audit_action
	)
	Select 
	header_number,
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	suser_sname(),
	getdate(),
	'D'
	from deleted


end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_apreconheader] on [dbo].[apreconheader] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
begin
	Insert into apreconheader_audit
	(header_number,	
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	audit_user,
	audit_dttm,
	audit_action
	)
	Select 
	header_number,
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	suser_sname(),
	getdate(),
	'I'
	from inserted


end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_apreconheader] on [dbo].[apreconheader] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
begin

	Insert into apreconheader_audit
	(header_number,	
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,
	header_status,
	ap_source,
	comments,
	err_msg,
	audit_user,
	audit_dttm,
	audit_action
	)
	Select 
	header_number,
	vendor_id,
	ap_invoice_number,
	ap_invoice_date,
	ap_total_invoice_amount,
--	vendor_city,
--	vendor_nmstct,
	vendor_location,
	rail_motor_flag,	
	header_status,
	ap_source,
	comments,
	err_msg,
	suser_sname(),
	getdate(),
	'U'
	from inserted


end

GO
ALTER TABLE [dbo].[apreconheader] ADD CONSTRAINT [pk_apreconheader] PRIMARY KEY CLUSTERED ([vendor_id], [ap_invoice_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_apreconheader] ON [dbo].[apreconheader] ([header_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[apreconheader] TO [public]
GO
GRANT INSERT ON  [dbo].[apreconheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[apreconheader] TO [public]
GO
GRANT SELECT ON  [dbo].[apreconheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[apreconheader] TO [public]
GO
