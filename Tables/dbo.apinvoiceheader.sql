CREATE TABLE [dbo].[apinvoiceheader]
(
[apv_number] [int] NOT NULL IDENTITY(1, 1),
[apv_vendorid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apv_invoicenumber] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apv_invoiceamount] [money] NOT NULL,
[apv_invoicedate] [datetime] NOT NULL,
[apv_createdby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__apinvoice__apv_c__5AE52C6F] DEFAULT (suser_sname()),
[apv_createddate] [datetime] NOT NULL CONSTRAINT [DF__apinvoice__apv_c__5BD950A8] DEFAULT (getdate()),
[apv_modifiedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__apinvoice__apv_m__5CCD74E1] DEFAULT (suser_sname()),
[apv_modifieddate] [datetime] NOT NULL CONSTRAINT [DF__apinvoice__apv_m__5DC1991A] DEFAULT (getdate()),
[apv_transferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apv_deductionthreshold] [money] NULL,
[apv_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apv_vouchernumber] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apv_docdescription] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apv_refnumber] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create trigger [dbo].[ut_apinvoiceheader] on [dbo].[apinvoiceheader] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

		--PTS 23691 CGK 9/3/2004
		DECLARE @tmwuser varchar (255)
		exec gettmwuser @tmwuser output

		update apinvoiceheader set apv_modifiedby = @tmwuser ,apv_modifieddate = current_timestamp
		from   inserted
		where inserted.apv_number = apinvoiceheader.apv_number
GO
ALTER TABLE [dbo].[apinvoiceheader] ADD CONSTRAINT [pk_apinvoiceheader] PRIMARY KEY CLUSTERED ([apv_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_apinvoiceheader] ON [dbo].[apinvoiceheader] ([apv_invoicenumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[apinvoiceheader] TO [public]
GO
GRANT INSERT ON  [dbo].[apinvoiceheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[apinvoiceheader] TO [public]
GO
GRANT SELECT ON  [dbo].[apinvoiceheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[apinvoiceheader] TO [public]
GO
