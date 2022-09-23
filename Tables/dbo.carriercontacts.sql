CREATE TABLE [dbo].[carriercontacts]
(
[cc_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cc_contact_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_fname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_lname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_phone1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_phone1_ext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_phone2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_phone2_ext] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_cell] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_fax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_default_carrier_addr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_cty_code] [int] NULL,
[cc_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_mail1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_mail2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_mail3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_mail_cty_code] [int] NULL,
[cc_mail_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NOT NULL,
[cc_updatedt] [datetime] NULL,
[cc_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_after_hours] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_hours_of_operation] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_carriercontacts] ON [dbo].[carriercontacts]
FOR INSERT,UPDATE
AS
DECLARE @min_id		INTEGER,
        @tmwuser 	VARCHAR(255)
exec gettmwuser @tmwuser output

SET @min_id = 0
SELECT @min_id = MIN(cc_id)
  FROM inserted
 WHERE cc_id > @min_id

WHILE @min_id > 0 
BEGIN

   IF @min_id IS NULL
      BREAK

   UPDATE carriercontacts
      SET cc_updatedby = @tmwuser,
          cc_updatedt = GETDATE()
    WHERE cc_id = @min_id

   SELECT @min_id = MIN(cc_id)
     FROM inserted
    WHERE cc_id > @min_id

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[uit_carriercontacts_carrier] ON [dbo].[carriercontacts]
FOR INSERT, UPDATE
AS

/**
 * 
 * NAME: 
 * dbo.uit_carriercontacts_carrier
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
	IF UPDATE (cc_default_carrier_addr)
	BEGIN
		SELECT 
			@car_id = inserted.car_id,
			@car_contact = inserted.cc_fname, 
			@car_phone1 = inserted.cc_phone1, 
			@car_phone2 = inserted.cc_phone2, 
			@car_phone3 = inserted.cc_fax, 
			@car_email = inserted.cc_email,
			@retired = inserted.cc_retired,
			@default = inserted.cc_default_carrier_addr
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
ALTER TABLE [dbo].[carriercontacts] ADD CONSTRAINT [pk_carriercontacts_cc_id] PRIMARY KEY CLUSTERED ([cc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriercontacts_car_id] ON [dbo].[carriercontacts] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriercontacts] TO [public]
GO
GRANT INSERT ON  [dbo].[carriercontacts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriercontacts] TO [public]
GO
GRANT SELECT ON  [dbo].[carriercontacts] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriercontacts] TO [public]
GO
