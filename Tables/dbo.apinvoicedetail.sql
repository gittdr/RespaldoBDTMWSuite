CREATE TABLE [dbo].[apinvoicedetail]
(
[apv_number] [int] NOT NULL,
[apd_number] [int] NOT NULL IDENTITY(1, 1),
[apd_asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apd_asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apd_pto_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apd_amount] [money] NOT NULL,
[apd_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[apd_createdby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__apinvoice__apd_c__609E05C5] DEFAULT (suser_sname()),
[apd_createddate] [datetime] NOT NULL CONSTRAINT [DF__apinvoice__apd_c__619229FE] DEFAULT (getdate()),
[apd_modifiedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__apinvoice__apd_m__62864E37] DEFAULT (suser_sname()),
[apd_modifieddate] [datetime] NOT NULL CONSTRAINT [DF__apinvoice__apd_m__637A7270] DEFAULT (getdate()),
[std_number] [int] NULL,
[sdm_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apd_deductionthreshold] [money] NULL,
[apd_glnumber] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apd_glindex] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create trigger [dbo].[ut_apinvoicedetail] on [dbo].[apinvoicedetail] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

		--PTS 23691 CGK 9/3/2004
		DECLARE @tmwuser varchar (255)
		exec gettmwuser @tmwuser output

		update apinvoicedetail set apd_modifiedby = @tmwuser ,apd_modifieddate = current_timestamp
		from   inserted
		where  inserted.apv_number = apinvoicedetail.apv_number and
			   inserted.apd_number = apinvoicedetail.apd_number
GO
ALTER TABLE [dbo].[apinvoicedetail] ADD CONSTRAINT [pk_apinvoicedetail] PRIMARY KEY CLUSTERED ([apv_number], [apd_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apinvoicedetail] ADD CONSTRAINT [fk_apinvoicedetail] FOREIGN KEY ([apv_number]) REFERENCES [dbo].[apinvoiceheader] ([apv_number])
GO
GRANT DELETE ON  [dbo].[apinvoicedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[apinvoicedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[apinvoicedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[apinvoicedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[apinvoicedetail] TO [public]
GO
