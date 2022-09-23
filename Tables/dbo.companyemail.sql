CREATE TABLE [dbo].[companyemail]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[email_address] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mail_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_id] [int] NOT NULL IDENTITY(1, 1),
[ce_phone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone1_ext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_phone2_ext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mobilenumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_faxnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_defaultcontact] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_fname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_cty_code] [int] NULL,
[ce_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mail_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mail_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mail_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mail_cty_code] [int] NULL,
[ce_mail_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_updatedt] [datetime] NULL,
[ce_contact_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_after_hours] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_hours_of_operation] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[iut_companyemail] 
   ON [dbo].[companyemail] For INSERT,DELETE,UPDATE
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

Declare @updatecount	int,
	@deletecount	int,
	@cmpid		varchar(8),
	@seq_count	int,
	@min_seq	int,
	@contact_id	int

	if (select count(*) from inserted) > 0
	begin
		update company
			set cmp_updateddate = getdate()
		from inserted
		where inserted.cmp_id = company.cmp_id
	end



if (select count(*) from inserted where inserted.type = 'S') > 0 AND COALESCE((SELECT TOP 1 gi_string1 FROM generalinfo WHERE gi_name = 'UpdateCompanyContactOnTriggers'), 'Y') = 'Y'
	Begin
		-- 06/12/2008 DZW PTS: 43190 move update of contact_name first to prevent
		-- uncalled for update of companyemail by ut_company trigger
		if Update(contact_name)
			update company 
			set cmp_contact = inserted.contact_name 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'				
				and (inserted.contact_name <> company.cmp_contact or company.cmp_contact is null)

		if Update(ce_phone1)
			update company 
			set cmp_primaryphone = inserted.ce_phone1 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and (inserted.ce_phone1 <> company.cmp_primaryphone or company.cmp_primaryphone is null)
				
		if Update(ce_faxnumber)
			update company 
			set cmp_faxphone = inserted.ce_faxnumber 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and (inserted.ce_faxnumber <> company.cmp_faxphone or company.cmp_faxphone is null)

		if Update(ce_phone1_ext)
			update company 
			set cmp_primaryphoneext = inserted.ce_phone1_ext 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and (inserted.ce_phone1_ext <> company.cmp_primaryphoneext or company.cmp_primaryphoneext is null)

		if Update(ce_phone2)
			update company 
			set cmp_secondaryphone = inserted.ce_phone2 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and (inserted.ce_phone2 <> company.cmp_secondaryphone or company.cmp_secondaryphone is null)

		if Update(ce_phone2_ext)
			update company 
			set cmp_secondaryphoneext = inserted.ce_phone2_ext 
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and (inserted.ce_phone2_ext <> company.cmp_secondaryphoneext or company.cmp_secondaryphoneext is null)

		if update(ce_defaultcontact)
			update company
			set cmp_contact = inserted.contact_name,
			cmp_primaryphone = inserted.ce_phone1,
			cmp_primaryphoneext = inserted.ce_phone1_ext,
			cmp_secondaryphone = inserted.ce_phone2,
			cmp_secondaryphoneext = inserted.ce_phone2_ext,
			cmp_faxphone = inserted.ce_faxnumber  
			from inserted
			where company.cmp_id = inserted.cmp_id
				and inserted.ce_defaultcontact = 'Y'
				and inserted.ce_source = 'CMP'
				and (isnull(cmp_primaryphone, 'XXX') <> isnull(inserted.ce_phone1, 'XXX')
					or isnull(cmp_primaryphoneext, 'XXX') <> isnull(inserted.ce_phone1_ext, 'XXX')
					or isnull(cmp_secondaryphone, 'XXX') <> isnull(inserted.ce_phone2, 'XXX')
					or isnull(cmp_secondaryphoneext, 'XXX') <> isnull(inserted.ce_phone2_ext, 'XXX')
					or isnull(cmp_faxphone, 'XXX') <> isnull(inserted.ce_faxnumber  , 'XXX')
					or isnull(cmp_contact, 'XXX') <> isnull(inserted.contact_name, 'XXX'))

	end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[uit_companyemail_carrier] ON [dbo].[companyemail]
FOR INSERT, UPDATE
AS

/**
 * 
 * NAME: 
 * dbo.uit_companyemail_carrier
 *
 * TYPE: 
 * Trigger
 *
 * DESCRIPTION:
 * Sets the carrier profile contact information when the default is changed.
 * Fields updated car_contact, car_phone1, car_phone2, car_phone3, car_email
 *
 * RETURNS: 
 * N/A
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS: 
 * N/A
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 2015/10/30 | PTS 81509 | kw	  - new trigger
 *
 **/

DECLARE
	@car_id			VARCHAR(8),
	@car_contact	VARCHAR(25),
	@car_phone1		CHAR(10),
	@car_phone2		CHAR(10),
	@car_phone3		CHAR(10),
	@car_email		VARCHAR(128),
	@retired		CHAR(1),
	@default		CHAR(1)

BEGIN
	IF UPDATE (ce_defaultcontact)
	BEGIN
		SELECT 
			@car_id = inserted.cmp_id,
			@car_contact = inserted.contact_name, 
			@car_phone1 = inserted.ce_phone1, 
			@car_phone2 = inserted.ce_phone2, 
			@car_phone3 = inserted.ce_faxnumber, 
			@car_email = inserted.email_address,
			@retired = inserted.ce_retired,
			@default = inserted.ce_defaultcontact
		FROM inserted
	END

	IF @retired = 'N' AND @default = 'Y'
	BEGIN
		UPDATE carrier
			SET 
				carrier.car_contact = @car_contact, 
				carrier.car_phone1 = @car_phone1, 
				carrier.car_phone2 = @car_phone2 , 
				carrier.car_phone3 = @car_phone3, 
				carrier.car_email = @car_email
			WHERE
				carrier.car_id = @car_id
	END

END
GO
ALTER TABLE [dbo].[companyemail] ADD CONSTRAINT [pk_ceid] PRIMARY KEY CLUSTERED ([ce_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cmp_id] ON [dbo].[companyemail] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companyemail] TO [public]
GO
GRANT INSERT ON  [dbo].[companyemail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[companyemail] TO [public]
GO
GRANT SELECT ON  [dbo].[companyemail] TO [public]
GO
GRANT UPDATE ON  [dbo].[companyemail] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'TABLE', N'companyemail', 'TRIGGER', N'iut_companyemail'
GO
