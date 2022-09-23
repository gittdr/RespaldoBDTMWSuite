CREATE TABLE [dbo].[aprecondetail]
(
[header_number] [int] NOT NULL,
[detail_sequence] [int] NOT NULL IDENTITY(1, 1),
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
[err_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create trigger [dbo].[dt_aprecondetail] on [dbo].[aprecondetail] for Delete as
BEGIN
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	Insert into aprecondetail_audit
		(header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		audit_user,
		audit_dttm,
		audit_action
		)
	Select
		header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		suser_sname(),
		getdate(),
		'D'
	From deleted
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create trigger [dbo].[it_aprecondetail] on [dbo].[aprecondetail] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
BEGIN
	Insert into aprecondetail_audit
		(	header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		audit_user,
		audit_dttm,
		audit_action
		)
	Select
		header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		suser_sname(),
		getdate(),
		'I'
	From inserted
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create trigger [dbo].[ut_aprecondetail] on [dbo].[aprecondetail] for Update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
BEGIN
	Insert into aprecondetail_audit
		(	header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		audit_user,
		audit_dttm,
		audit_action
		)
	Select
		header_number,
		detail_sequence,
		vendor_id,
		ap_invoice_number,
		lgh_number,
		equipment_number,
		original_detail_amount,
		actual_detail_amount,
		force_pay_flag,
		short_pay_flag,									 	
		detail_status, 
		comments,
		err_msg,
		suser_sname(),
		getdate(),
		'U'
	From inserted
END

GO
ALTER TABLE [dbo].[aprecondetail] ADD CONSTRAINT [pk_aprecondetail] PRIMARY KEY CLUSTERED ([vendor_id], [ap_invoice_number], [lgh_number], [equipment_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_aprecondetail] ON [dbo].[aprecondetail] ([header_number], [detail_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[aprecondetail] TO [public]
GO
GRANT INSERT ON  [dbo].[aprecondetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[aprecondetail] TO [public]
GO
GRANT SELECT ON  [dbo].[aprecondetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[aprecondetail] TO [public]
GO
